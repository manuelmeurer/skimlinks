require 'active_support/hash_with_indifferent_access'

module Skimlinks
  class Merchant
    attr_accessor :id, :name, :preferred, :updated_at, :average_conversion_rate, :average_commission, :logo_url, :domains, :categories, :countries, :product_count

    class << self
      def build_from_api_response(merchant_data)
        merchant_data.map do |merchant|
          self.new \
            :id                      => merchant['merchantID'].to_i,
            :name                    => merchant['merchantName'].presence,
            :preferred               => HashWithIndifferentAccess.new(merchant['preferred']),
            :updated_at              => merchant['dateUpdated'].present? ? Time.parse(merchant['dateUpdated']) : nil,
            :average_conversion_rate => merchant['averageConversionRate'].presence,
            :average_commission      => merchant['averageCommission'].presence,
            :logo_url                => merchant['logo'].presence,
            :domains                 => HashWithIndifferentAccess.new(merchant['domains']),
            :categories              => HashWithIndifferentAccess.new(merchant['categories']),
            :countries               => Array(merchant['countries'].presence),
            :product_count           => merchant['productCount'].to_i
        end.sort_by(&:name)
      end
    end

    def initialize(args = {})
      args.each do |k, v|
        self.send "#{k}=", v
      end
    end

    def preferred?
      self.preferred.present?
    end
  end
end
