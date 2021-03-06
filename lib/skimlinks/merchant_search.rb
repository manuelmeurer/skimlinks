module Skimlinks
  class MerchantSearch
    include Skimlinks::SearchHelpers

    ATTRIBUTES = %w(
      query
      category_ids
      country
      exclude_no_products
      include_product_count
    )
    COUNTRY_ALIASES = {
      de: [
        'germany',
        'international'
      ],
      uk: [
        'united kingdom',
        'international'
      ],
      us: [
        'united states',
        'international'
      ]
    }

    attr_accessor *ATTRIBUTES

    def categories
      @categories ||= begin
        flatten = ->(data, prefix = nil) {
          data.each_with_object({}) do |(_, data), hash|
            name       = [prefix, data['name']].compact.join(' > ')
            hash[name] = data['id'].to_i
            hash.merge! flatten.call(data['children'], name) if data['children'].present?
          end
        }

        flatten.call client.merchant_categories
      end
    end

    def merchant(id)
      @merchant ||= {}
      @merchant[id] ||= self.merchants.detect { |merchant| merchant.id.to_s == id.to_s }
    end

    def merchants(args = {})
      args = args.dup.reverse_merge(
        ATTRIBUTES.each_with_object({}) do |attribute, hash|
          hash[attribute.to_sym] = self.send(attribute) unless self.send(attribute).nil?
        end
      )

      args.assert_valid_keys(ATTRIBUTES.map(&:to_sym))

      raise ArgumentError, "If exclude_no_products is set to true, include_product_count must also be true." if args[:exclude_no_products] && !args[:include_product_count]

      @merchants ||= {}
      @merchants[args] ||= begin
        merchant_data = case
        when args[:query].blank? && args[:category_ids].blank?
          merchants_in_categories(client.merchant_category_ids)
        when args[:query].present? && args[:category_ids].present?
          merchants_in_categories(args[:category_ids]) & client.merchant_search(args[:query])
        when args[:query].present?
          client.merchant_search(args[:query])
        else
          merchants_in_categories(args[:category_ids])
        end

        raise StandardError, "No country aliases for #{args[:country]} found." if args[:country].present? && !COUNTRY_ALIASES.has_key?(args[:country].to_sym)

        if args[:country].present?
          merchant_data.reject! do |merchant|
            merchant['countries'].present? && (COUNTRY_ALIASES[args[:country].to_sym] & merchant['countries']).empty?
          end
        end

        merchants = Merchant.build_from_api_response(merchant_data)

        if args[:include_product_count]
          merchants.each do |merchant|
            merchant.product_count = client.product_count(merchant_id: merchant.id)
          end

          if args[:exclude_no_products]
            merchants.reject! do |merchant|
              merchant.product_count == 0
            end
          end
        end

        merchants
      end
    end

    private

    def merchants_in_categories(category_ids)
      Array(category_ids).map do |category_id|
        client.merchants_in_category(category_id)
      end.flatten.uniq
    end
  end
end
