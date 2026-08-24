# Subcategory Control

Limits how many levels of subcategories each Discourse category listing renders,
without changing the category structure itself. The sidebar, category chooser, topic lists and permissions are all untouched — only the category lists change.

Deep category lists can make `/categories` hard to scan or asymmetrical, but the nesting is still worth keeping for navigation. This component keeps the lists shallow.

### Three levels needs a site setting

Discourse allows two levels of category nesting by default, so anything here
that adds a third level — `categories_page_depth: 3`, or either
`show_grandchildren_*` setting — has nothing to show until the site allows a
third. That is the `max_category_nesting` site setting, which defaults to `2`
and accepts at most `3`. It is hidden, so it is set from the rails console
rather than the admin settings UI:

```ruby
SiteSetting.max_category_nesting = 3
```

## Custom category pages

If you run a component that replaces the categories page with a custom
rendering, this component won't reach it unless it resolves its lists through the core helper:

```js
import categoryListSubcategories from "discourse/helpers/category-list-subcategories";

const subcategories = categoryListSubcategories(category, { page });
```
