module Skimlinks
  class MerchantSearch
    attr_accessor :locale, :exclude_no_products

    def initialize(args = {})
      args.each do |k, v|
        self.send "#{k}=", v
      end

      @exclude_no_products = false if @exclude_no_products.nil?
      @api = Skimlinks::Api.new
    end

    def merchant(id)
      cache_key = [
        'skimlinks',
        'merchant',
        id
      ].join(':')

      Rails.cache.fetch cache_key, expires_in: 1.week do
        self.merchants.detect { |merchant| merchant.id == id } or raise StandardError, "Skimlinks merchant with id #{id} not found."
      end
    end
    # memoize :merchant

    def merchants
      cache_key = [
        'skimlinks',
        'merchants',
        @locale || 'all_locales',
        "#{@exclude_no_products ? 'ex' : 'in'}clude_no_products"
      ].join(':')

      Rails.cache.fetch cache_key, expires_in: 1.week do
        merchant_data = @api.merchant_category_ids.map do |category_id|
          self.merchants_in_category(category_id)
        end.flatten.uniq
        Merchant.build_from_api_response(merchant_data)
      end
    end
    # memoize :merchants

    def merchants_in_category(category_id)
      cache_key = [
        'skimlinks',
        'merchants_in_category',
        category_id,
        @locale || 'all_locales',
        "#{@exclude_no_products ? 'ex' : 'in'}clude_no_products"
      ].join(':')

      Rails.cache.fetch cache_key, expires_in: 4.weeks do
        @api.merchants(category_id, @locale, @exclude_no_products)
      end
    end
    # memoize :merchants_in_category
  end
end
