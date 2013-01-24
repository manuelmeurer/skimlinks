require 'active_support/core_ext/hash'

module Skimlinks
  class ProductSearch
    include Skimlinks::SearchHelpers

    LOCALES = %w(
      de
      us
      uk
    )
    SEARCH_PARAMS = %w(
      ids
      query
      locale
      min_price
      max_price
      merchant_id
      category
    )

    attr_accessor :rows, :page, *SEARCH_PARAMS

    def categories
      Hash[
        client.product_categories
          .invert
          .sort
          .map { |category, id| [category, id.to_i] }
      ]
    end

    def products(args = {})
      product_data = client.product_search(search_params(args))
      Product.build_from_api_response(product_data)
    end

    def product_count(args = {})
      client.product_count(search_params(args))
    end

    private

    def search_params(args = {})
      args = args.dup.reverse_merge((SEARCH_PARAMS + [:rows, :page]).each_with_object({}) { |search_param, hash| hash[search_param.to_sym] = self.send(search_param) unless self.send(search_param).nil? })

      raise Skimlinks::InvalidParameters, "One of these params must be set: #{SEARCH_PARAMS.join(', ')}" if SEARCH_PARAMS.none? { |param| args.has_key?(param.to_sym) }
      raise Skimlinks::InvalidParameters, "Locale #{args[:locale]} is not a valid locale. Valid locales are #{LOCALES.join(', ')}" if args[:locale].present? && !LOCALES.include?(args[:locale])

      category_ids = if args[:category].present?
        self.categories.select { |category, id| category =~ /^#{Regexp.escape(args[:category])}/ }.values.tap do |c_ids|
          raise Skimlinks::InvalidParameters, %(No category IDs for category "#{args[:category]}" found) if c_ids.empty?
        end
      else
        []
      end

      {}.tap do |params|
        %w(ids query locale min_price max_price merchant_id rows).each do |arg|
          params[arg.to_sym] = args[arg.to_sym] if args.has_key?(arg.to_sym)
        end
        params[:category_ids] = category_ids                         if category_ids.present?
        params[:start]        = (args[:page].to_i - 1) * args[:rows] if args[:page].present? && args[:rows].present?
      end
    end
  end
end
