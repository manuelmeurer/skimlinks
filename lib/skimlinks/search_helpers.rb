require 'active_support/concern'

module Skimlinks
  module SearchHelpers
    extend ActiveSupport::Concern

    def initialize(args = {})
      args.each do |k, v|
        self.send "#{k}=", v
      end
    end

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
