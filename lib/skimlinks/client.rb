require 'json'
require 'rest-client'
require 'mechanize'

module Skimlinks
  class Client
    API_ENDPOINTS = {
      product_api:  'http://api-product.skimlinks.com/',
      merchant_api: 'http://api-merchants.skimlinks.com/merchants/',
      link_api:     'http://go.productwidgets.com/'
    }

    attr_accessor *Configuration::VALID_CONFIG_KEYS

    def initialize(args = {})
      options = Skimlinks.configuration.options.merge(args)

      Configuration::VALID_CONFIG_KEYS.each do |key|
        self.send "#{key}=", options[key]
      end

      @product_api  = RestClient::Resource.new(API_ENDPOINTS[:product_api])
      @merchant_api = RestClient::Resource.new(API_ENDPOINTS[:merchant_api])
      @mechanize    = Mechanize.new do |m|
        m.agent.redirect_ok      = false
        m.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
    end

    # Product API

    def product_search(args)
      product_count_and_products(args).last
    end

    def product_count(args)
      product_count_and_products(args.merge(rows: 0)).first
    end

    def product_categories
      @product_categories ||= product_api('categories')['skimlinksProductAPI']['categories']
    end

    # Merchant API

    def merchant_categories
      @merchant_categories ||= merchant_api('categories')
    end

    def merchant_category_ids
      @merchant_category_ids ||= flatten(self.merchant_categories).grep(/^\d+$/).uniq.map(&:to_i)
    end

    def merchants_in_category(category_id)
      [].tap do |merchants|
        start, found = 0, nil

        while found.nil? || start < found
          data = merchant_api('category', category_id, 'limit', 200, 'start', start)

          merchants.concat data['merchants'] if data['merchants'].present?

          start = data['numStarted'].to_i + data['numReturned'].to_i
          found = data['numFound']
        end
      end
    end

    def merchant_search(query, preferred = false)
      [].tap do |merchants|
        start, found = 0, nil

        while found.nil? || start < found
          data = merchant_api('search', query, 'limit', 200, 'start', start, preferred ? '?filter_by=preferred' : nil)

          merchants.concat data['merchants'] if data['merchants'].present?

          start = data['numStarted'].to_i + data['numReturned'].to_i
          found = data['numFound']
        end
      end
    end

    # Link API

    def affiliate(url, publisher_id)
      link_api url, publisher_id
    end

    private

    def flatten(object)
      case object
      when Hash
        object.to_a.map { |v| flatten(v) }.flatten
      when Array
        object.flatten.map { |v| flatten(v) }
      else
        object
      end
    end

    def returning_json(&block)
      JSON.parse block.call
    end

    def returning_xml(&block)
      Nokogiri::XML block.call
    end

    def product_count_and_products(args)
      api_query = []
      api_query << %(id:(#{args[:ids].join(' ')}))                                                          if args[:ids].present?
      api_query << %((#{%w(title description).map { |field| %(#{field}:"#{args[:query]}") }.join(' OR ')})) if args[:query].present?
      api_query << %(price:[#{args[:min_price].presence || '*'} TO #{args[:max_price].presence || '*'}])    if args[:min_price].present? || args[:max_price].present?
      api_query << %(categoryId:(#{args[:category_ids].join(' ')}))                                         if args[:category_ids].present?
      api_query << %(merchantId:"#{args[:merchant_id]}")                                                    if args[:merchant_id].present?
      api_query << %(country:"#{args[:country]}")                                                           if args[:country].present?
      api_query << %(currency:"#{args[:currency]}")                                                         if args[:currency].present?

      # TODO: Check for categoryId 0, '' or nil, missing categoryId

      query_params = {
        q: api_query.join(' AND ')
      }
      query_params[:rows]  = args[:rows]  if args[:rows].present?
      query_params[:start] = args[:start] if args[:start].present?

      product_data = product_api('query', query_params)['skimlinksProductAPI']

      [product_data['numFound'], product_data['products']]
    end

    def get(api, path, params = {})
      raise Skimlinks::InvalidParameters, 'Only JSON format is supported right now.' unless Skimlinks.configuration.format == :json

      do_get = lambda do
        returning_json do
          api[URI.escape(path)].get params: params
        end
      end

      if Skimlinks.configuration.cache.nil?
        do_get.call
      else
        cache_key = [
          'skimlinks',
          'api',
          Digest::MD5.hexdigest(api.to_s + path + params.to_s)
        ].join(':')
        cache_options = Skimlinks.configuration.cache_ttl > 0 ? { expires_in: Skimlinks.configuration.cache_ttl } : {}
        Skimlinks.configuration.cache.fetch cache_key, cache_options do
          do_get.call
        end
      end
    rescue RestClient::Exception => e
      message = [e.message].tap do |message_parts|
        error = JSON.parse(e.response)['skimlinksProductAPI']['message'] rescue nil
        message_parts << error if error.present?
      end.join(' - ')
      raise Skimlinks::ApiError, message
    end

    def product_api(method, params = {})
      raise Skimlinks::InvalidParameters, 'API key not configured' if Skimlinks.configuration.api_key.blank?

      params = params.reverse_merge(
        format: Skimlinks.configuration.format,
        key:    Skimlinks.configuration.api_key
      )

      get(@product_api, method, params).tap do |response|
        raise Skimlinks::InvalidParameters, 'API key is invalid' if response.is_a?(Array) && response.first =~ /^Invalid API key/
      end
    end

    def merchant_api(method, *params)
      raise Skimlinks::InvalidParameters, 'API key not configured' if Skimlinks.configuration.api_key.blank?

      path = [
        Skimlinks.configuration.format,
        Skimlinks.configuration.api_key,
        method,
        *params.compact
      ].join('/')

      get(@merchant_api, path).tap do |response|
        raise Skimlinks::InvalidParameters, 'API key is invalid' if response.is_a?(Array) && response.first =~ /^Invalid API key/
      end
    end

    def link_api(url, publisher_id)
      query_params = { url: CGI.escape(url), id: publisher_id, xs: 1 }
      path         = [API_ENDPOINTS[:link_api], URI.encode_www_form(query_params)].join('?')
      response     = @mechanize.head(path)

      raise Skimlinks::ApiError, "Unexpected response code: #{response.code}" unless response.code == '302'

      redirect_location = response['location']
      case redirect_location
      when url, %r(http://www\.google\.com/search\?q=)
        nil
      else
        redirect_location
      end
    end
  end
end
