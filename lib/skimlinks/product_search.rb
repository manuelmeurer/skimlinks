require 'active_model/naming'
require 'active_model/translation'
require 'active_model/validator'
require 'active_model/validations'

module Skimlinks
  class ProductSearch
    extend ActiveModel::Naming
    extend ActiveModel::Translation

    include ActiveModel::Validations

    LOCALES = %w(
      us
      uk
    )
    REQUIRED_PARAMS = %w(
      ids
      query
      locale
      min_price
      max_price
      merchant_id
      category
    )

    attr_accessor :ids, :query, :category, :page, :locale, :merchant_id, :min_price, :max_price, :rows

    validates :page, presence: true, numericality: true
    validates :locale, presence: true, inclusion: LOCALES
    validates :rows, presence: true, numericality: true

    validate do
      self.errors.add :base, "One of these params must be set: #{REQUIRED_PARAMS.join(', ')}" if REQUIRED_PARAMS.all? { |param| instance_variable_get("@#{param}").blank? }
    end

    def initialize(args = {})
      args.each do |k, v|
        self.send "#{k}=", v
      end

      @client = Skimlinks::Client.new
    end

    class << self
      def category_list
        Hash[
          Skimlinks::Client.new.product_categories
            .invert
            .sort
            .map { |category, id| [category, id.to_i] }
        ]
      end

      def category_hash
        {}.tap do |all_categories|
          self.category_list.each do |category, id|
            category_hash = category.split(' > ').reverse.inject({}) do |hash, category_part|
              { category_part => hash.presence }
            end
            all_categories.deep_merge! category_hash
          end
        end
      end
    end

    def products
      category_ids = if @category.present?
        self.class.category_list.select { |category, id| category =~ /^#{Regexp.escape(@category)}/ }.values.tap do |c_ids|
          raise StandardError, "No category IDs for category #{@category} found" if c_ids.empty?
        end
      else
        []
      end

      params = {
        ids:          @ids,
        query:        @query,
        merchant_id:  @merchant_id,
        locale:       @locale,
        min_price:    @min_price,
        max_price:    @max_price,
        category_ids: category_ids,
        rows:         @rows,
        start:        (@page.to_i - 1) * @rows
      }

      @product_count, product_data = @client.product_search(params)

      Product.build_from_api_response(product_data)
    end

    def product_count
      self.products if @product_count.nil?
      @product_count
    end
  end
end
