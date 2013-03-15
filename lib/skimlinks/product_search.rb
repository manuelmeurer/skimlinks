require 'active_support/core_ext/hash'

module Skimlinks
  class ProductSearch
    include Skimlinks::SearchHelpers

    COUNTRIES = %w(
      us
      uk
    )
    ATTRIBUTES = %w(
      rows
      page
      ids
      query
      country
      min_price
      max_price
      merchant_id
      category
    )

    attr_accessor *ATTRIBUTES

    def categories
      @categories ||= Hash[
        client.product_categories
          .invert
          .sort
          .map { |category, id| [category, id.to_i] }
      ]
    end

    def products(args = {})
      @products ||= {}
      @products[args] ||= begin
        product_data = client.product_search(search_params(args))
        Product.build_from_api_response(product_data)
      end
    end

    def product_count(args = {})
      @product_count ||= {}
      @product_count[args] ||= client.product_count(search_params(args))
    end

    private

    def search_params(args = {})
      args = args.dup.reverse_merge(
        ATTRIBUTES.each_with_object({}) do |attribute, hash|
          hash[attribute.to_sym] = self.send(attribute) unless self.send(attribute).nil?
        end
      )

      args.assert_valid_keys(ATTRIBUTES.map(&:to_sym))

      raise Skimlinks::InvalidParameters, "Locale #{args[:country]} is not a valid country. Valid countries are #{COUNTRIES.join(', ')}" if args[:country].present? && !COUNTRIES.include?(args[:country])

      category_ids = if args[:category].present?
        self.categories.select { |category, id| category =~ /^#{Regexp.escape(args[:category])}/ }.values.tap do |c_ids|
          raise Skimlinks::InvalidParameters, %(No category IDs for category "#{args[:category]}" found) if c_ids.empty?
        end
      else
        []
      end

      {}.tap do |params|
        %w(ids query country min_price max_price merchant_id rows).each do |arg|
          params[arg.to_sym] = args[arg.to_sym] if args.has_key?(arg.to_sym)
        end
        params[:category_ids] = category_ids                         if category_ids.present?
        params[:start]        = (args[:page].to_i - 1) * args[:rows] if args[:page].present? && args[:rows].present?
      end
    end
  end
end
