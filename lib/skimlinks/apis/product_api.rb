require 'active_support/core_ext/hash'

module Skimlinks
  class ProductApi
    extend Skimlinks::ApiHelpers

    LOCALES = %w(
      de
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

    class << self
      def categories
        Hash[
          client.product_categories
            .invert
            .sort
            .map { |category, id| [category, id.to_i] }
        ]
      end

      def products(args = {})
        product_data = client.product_search(product_search_params(args))
        Product.build_from_api_response(product_data)
      end

      def product_count(args = {})
        client.product_count(product_search_params(args))
      end

      private

      def product_search_params(args)
        raise Skimlinks::InvalidParameters, "One of these params must be set: #{REQUIRED_PARAMS.join(', ')}" if REQUIRED_PARAMS.none? { |param| args.has_key?(param.to_sym) }
        raise Skimlinks::InvalidParameters, "Locale #{args[:locale]} is not a valid locale. Valid locales are #{VALID_LOCALES.join(', ')}" if args[:locale].present? && !LOCALES.include?(args[:locale])

        category_ids = if args[:category].present?
          self.categories.select { |category, id| category =~ /^#{Regexp.escape(args[:category])}/ }.values.tap do |c_ids|
            raise Skimlinks::InvalidParameters, %(No category IDs for category "#{args[:category]}" found) if c_ids.empty?
          end
        else
          []
        end

        {}.tap do |params|
          [:ids, :query, :merchant_id, :locale, :min_price, :max_price, :rows].each do |arg|
            params[arg] = args[arg] if args.has_key?(arg)
          end
          params[:category_ids] = category_ids                         if category_ids.present?
          params[:start]        = (args[:page].to_i - 1) * args[:rows] if args[:page].present? && args[:rows].present?
        end
      end
    end
  end
end
