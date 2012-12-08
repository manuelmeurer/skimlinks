module Skimlinks
  class MerchantApi
    extend Skimlinks::ApiHelpers

    class << self
      def categories
        flatten = ->(data, prefix = nil) {
          data.each_with_object({}) do |(_, data), hash|
            name       = [prefix, data['name']].compact.join(' > ')
            hash[name] = data['id'].to_i
            hash.merge! flatten.call(data['children'], name) if data['children'].present?
          end
        }

        flatten.call client.merchant_categories
      end

      def merchant(id)
        self.merchants.detect { |merchant| merchant.id == id }
      end

      def merchants(args = {})
        category_ids = if args[:category_ids].present?
          Array(args[:category_ids])
        else
          client.merchant_category_ids
        end

        merchant_data = category_ids.map do |category_id|
          client.merchants(category_id, args[:locale], args[:exclude_no_products])
        end.flatten.uniq

        Merchant.build_from_api_response(merchant_data)
      end
    end
  end
end
