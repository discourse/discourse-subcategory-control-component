# frozen_string_literal: true

require_relative "page_objects/components/category_list"

RSpec.describe "Subcategory control" do
  let!(:theme) { upload_theme_component }

  before do
    SiteSetting.max_category_nesting = 3
    SiteSetting.desktop_category_page_style = "categories_only"
  end

  let!(:category) { Fabricate(:category, name: "General") }
  let!(:subcategory) { Fabricate(:category, parent_category: category) }
  let!(:sub_subcategory) { Fabricate(:category, parent_category: subcategory) }
  let!(:other_category) { Fabricate(:category, name: "Other") }
  let!(:other_subcategory) { Fabricate(:category, parent_category: other_category) }
  let!(:other_sub_subcategory) { Fabricate(:category, parent_category: other_subcategory) }

  let(:category_list) { PageObjects::Components::CategoryList.new }

  it "shows two levels on the categories page by default" do
    visit("/categories")

    expect(category_list).to have_category(subcategory)
    expect(category_list).to have_no_category(sub_subcategory)
  end

  it "shows a third level, or none, as `categories_page_depth` says" do
    theme.update_setting(:categories_page_depth, 3)
    theme.save!

    visit("/categories")

    expect(category_list).to have_category(sub_subcategory)

    theme.update_setting(:categories_page_depth, 1)
    theme.save!

    visit("/categories")

    expect(category_list).to have_no_category(subcategory)
  end

  it "keeps a chosen branch expanded below the category that was chosen" do
    theme.update_setting(:always_expanded_categories, category.id.to_s)
    theme.save!

    visit("/categories")

    expect(category_list).to have_category(sub_subcategory)
    expect(category_list).to have_no_category(other_sub_subcategory)
  end

  it "collapses a chosen branch however deep the page would otherwise go" do
    theme.update_setting(:categories_page_depth, 3)
    theme.update_setting(:never_expanded_categories, category.id.to_s)
    theme.save!

    visit("/categories")

    expect(category_list).to have_no_category(subcategory)
    expect(category_list).to have_category(other_sub_subcategory)
  end

  it "shows or hides the third level above a category's topics, per its own setting" do
    category.update!(show_subcategory_list: true, subcategory_list_style: "rows")
    theme.update_setting(:show_grandchildren_above_topic_lists, false)
    theme.save!

    visit(category.url)

    expect(category_list).to have_category(subcategory)
    expect(category_list).to have_no_category(sub_subcategory)

    theme.update_setting(:show_grandchildren_above_topic_lists, true)
    theme.save!

    visit(category.url)

    expect(category_list).to have_category(sub_subcategory)
  end

  it "keeps the third level on a category's subcategories page" do
    theme.update_setting(:show_grandchildren_on_subcategories_page, true)
    theme.save!

    visit("#{category.url}/subcategories")

    expect(category_list).to have_category(sub_subcategory)

    theme.update_setting(:show_grandchildren_on_subcategories_page, false)
    theme.save!

    visit("#{category.url}/subcategories")

    expect(category_list).to have_no_category(sub_subcategory)
  end
end
