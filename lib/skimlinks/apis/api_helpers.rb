module Skimlinks
  module ApiHelpers
    def nested_categories
      {}.tap do |all_categories|
        self.categories.each do |category, id|
          nested_categories = category.split(' > ').reverse.inject({}) do |hash, category_part|
            { category_part => hash.presence }
          end
          all_categories.deep_merge! nested_categories
        end
      end
    end

    private

    def client
      @client ||= Skimlinks::Client.new
    end
  end
end
