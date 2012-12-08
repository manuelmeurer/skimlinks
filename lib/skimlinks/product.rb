module Skimlinks
  class Product
    attr_accessor :id, :name, :url, :description, :merchant, :country, :price, :currency, :category, :image_urls

    class << self
      def build_from_api_response(product_data)
        product_data.map do |product|
          description = product['description']
            .strip             # Remove leading and trailing whitespace
            .gsub(/\n+/, "\n") # Replace multiple \n's by single ones

          category = ProductApi.categories.invert[product['categorisation']['categoryId'].to_i] || 'empty'

          self.new \
            id:          product['id'],
            name:        product['title'],
            url:         product['url'],
            description: description,
            merchant:    product['merchant'],
            country:     product['country'],
            price:       product['price'],
            currency:    product['currency'].downcase,
            category:    category,
            image_urls:  product['imageUrl'].present? ? [URI(product['imageUrl'])] : []
        end
      end

      def affiliate_url(url, publisher_id = nil)
        publisher_id ||= Settings.skimlinks.publisher_id
        Skimlinks::Client.new.affiliate url, publisher_id
      end
    end

    def initialize(args = {})
      args.each do |k, v|
        self.send "#{k}=", v
      end
    end
  end
end
