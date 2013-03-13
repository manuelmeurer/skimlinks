module Skimlinks
  class MerchantSearch
    include Skimlinks::SearchHelpers

    attr_accessor :query, :category_ids, :locale, :exclude_no_products

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
      @merchant[id] ||= self.merchants.detect { |merchant| merchant.id == id }
    end

    def merchants(args = {})
      @merchants ||= {}
      @merchants[args] ||= begin
        args = args.dup.reverse_merge([:query, :category_ids, :locale, :exclude_no_products].each_with_object({}) { |search_param, hash| hash[search_param] = self.send(search_param) unless self.send(search_param).nil? })

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

        Merchant.build_from_api_response(merchant_data)
      end
    end

    private

    def merchants_in_categories(category_ids, args)
      Array(category_ids).map do |category_id|
        client.merchants_in_category(category_id, args[:locale], args[:exclude_no_products])
      end.flatten.uniq
    end
  end
end
