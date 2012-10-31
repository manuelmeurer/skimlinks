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
      self.merchants.detect { |merchant| merchant.id == id } or raise StandardError, "Skimlinks merchant with id #{id} not found."
    end

    def merchants
      merchant_data = @api.merchant_category_ids.map do |category_id|
        self.merchants_in_category(category_id)
      end.flatten.uniq
      Merchant.build_from_api_response(merchant_data)
    end

    def merchants_in_category(category_id)
      @api.merchants(category_id, @locale, @exclude_no_products)
    end
  end
end
