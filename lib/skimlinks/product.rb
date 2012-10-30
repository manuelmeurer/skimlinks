module Skimlinks
  class Product
    attr_accessor :id, :name, :url, :description, :merchant, :country, :price, :currency, :category, :image_urls

    class << self
      def build_from_api_response(product_data)
        product_data.map do |product|
          description = HTML::FullSanitizer.new.sanitize( # Strip tags
            product['description']
              .strip                     # Remove leading and trailing whitespace
              .gsub(%r(<br\s?/?>), "\n") # Replace <br> by \n
              .gsub(%r(</p>), "\n")      # Replace </p> by \n
              .gsub(/\n+/, "\n")         # Replace multiple \n's by single ones
          )

          category = ProductSearch.category_list.invert[product['categorisation']['categoryId'].to_i] || 'empty'

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
        Skimlinks::Api.new.affiliate url, publisher_id
      end
    end

    def initialize(args = {})
      args.each do |k, v|
        self.send "#{k}=", v
      end
    end

    def rating_fetchable?
      Amazon::Product.new(url: self.url).valid?
    end

    def rating_cache_key
      amazon_product = Amazon::Product.new(url: self.url)
      [
        'amazon',
        'ratings',
        amazon_product.locale.downcase,
        amazon_product.id
      ].join(':')
    end

    def rating_cached?
      Rails.cache.exist? self.rating_cache_key
    end

    def rating
      raise StandardError, 'Rating cannot be fetched for this search product.' unless self.rating_fetchable?

      amazon_product = Amazon::Product.new(url: self.url)
      locale         = amazon_product.locale
      product_id     = amazon_product.id

      Rails.cache.fetch self.rating_cache_key, expires_in: 1.week do
        Amazon::ProductSearch.new(locale: locale, query: product_id).rating
      end
    end

    def rounded_rating
      (self.rating * 2).round / 2.0
    end

    def unique_identifier
      self.id
    end
  end
end
