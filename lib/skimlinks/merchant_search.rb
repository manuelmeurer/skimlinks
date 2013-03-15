module Skimlinks
  class MerchantSearch
    include Skimlinks::SearchHelpers

    ATTRIBUTES = %w(
      query
      category_ids
      locale
      exclude_no_products
      include_product_count
    )

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
          merchants_in_categories(client.merchant_category_ids, args)
        when args[:query].present? && args[:category_ids].present?
          merchants_in_categories(args[:category_ids], args) & client.merchant_search(args[:query])
        when args[:query].present?
          client.merchant_search(args[:query])
        else
          merchants_in_categories(args[:category_ids], args)
        end

        if args[:include_product_count]
          merchant_data.map! do |merchant|
            merchant.merge! 'productCount' => client.product_count(merchant_id: merchant['merchantID'])
          end

          if args[:exclude_no_products]
            merchant_data.reject! do |merchant|
              merchant['productCount'] == 0
            end
          end
        end

        Merchant.build_from_api_response(merchant_data)
      end
    end

    private

    def merchants_in_categories(category_ids, args)
      Array(category_ids).map do |category_id|
        client.merchants_in_category(category_id, args[:locale])
      end.flatten.uniq
    end
  end
end
