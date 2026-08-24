# frozen_string_literal: true

module PageObjects
  module Components
    class CategoryList < PageObjects::Components::Base
      SELECTOR = ".category-list"

      def has_category?(category)
        has_css?(selector_for(category))
      end

      def has_no_category?(category)
        has_no_css?(selector_for(category))
      end

      private

      def selector_for(category)
        # Rows carry the id, and so do the badges the flatter layouts link with.
        "#{SELECTOR} [data-category-id='#{category.id}']"
      end
    end
  end
end
