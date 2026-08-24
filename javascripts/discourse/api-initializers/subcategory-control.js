import { apiInitializer } from "discourse/lib/api";

function categoryIds(setting) {
  return new Set(
    String(setting ?? "")
      .split("|")
      .filter(Boolean)
      .map((id) => parseInt(id, 10))
  );
}

export default apiInitializer((api) => {
  const alwaysExpanded = categoryIds(settings.always_expanded_categories);
  const neverExpanded = categoryIds(settings.never_expanded_categories);
  const depth = parseInt(settings.categories_page_depth, 10);

  function overrideFor(category) {
    for (let current = category; current; current = current.parentCategory) {
      if (neverExpanded.has(current.id)) {
        return "never";
      }

      if (alwaysExpanded.has(current.id)) {
        return "always";
      }
    }
  }

  api.registerValueTransformer(
    "category-list-subcategories",
    ({ value, context }) => {
      const { category, page } = context;

      if (!category) {
        return value;
      }

      const override = overrideFor(category);
      if (override) {
        return override === "never" ? [] : value;
      }

      if (!page) {
        return value;
      }

      switch (page) {
        case "categories":
          return category.level + 2 > depth ? [] : value;
        case "subcategories":
          return settings.show_grandchildren_on_subcategories_page ? value : [];
        case "category":
          return settings.show_grandchildren_above_topic_lists ? value : [];
      }

      return value;
    }
  );
});
