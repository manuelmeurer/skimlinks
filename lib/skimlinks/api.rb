require 'json'
require 'rest-client'
require 'mechanize'

module Skimlinks
  class Api
    Endpoints = {
      :product_api  => 'http://api-product.skimlinks.com/',
      :merchant_api => 'http://api-merchants.skimlinks.com/merchants/',
      :link_api     => 'http://go.productwidgets.com/'
    }
    DefaultParams = {
      :product_api => {
        :format => 'json'
      },
      :merchant_api => {
        :format => 'json'
      },
      :link_api => {
        :xs => 1
      }
    }
    RequiredParams = %w(
      ids
      query
      locale
      min_price
      max_price
      merchant_id
      category_ids
    )
    LocaleMerchantCountries = {
      :uk => [
        'united kingdom',
        'international'
      ],
      :us => [
        'united states',
        'international'
      ]
    }

    def initialize
      @product_api  = RestClient::Resource.new(Endpoints[:product_api])
      @merchant_api = RestClient::Resource.new(Endpoints[:merchant_api])
      @mechanize    = Mechanize.new do |m|
        m.agent.redirect_ok      = false
        m.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
    end

    def product_search(params)
      raise StandardError, "One of these params must be set: #{RequiredParams.join(', ')}" if RequiredParams.all? { |param| params[param.to_sym].blank? }

      returning_count_and_products do
        api_query = []
        api_query << %(id:(#{params[:ids].join(' ')}))                                                          if params[:ids].present?
        api_query << %((#{%w(title description).map { |field| %(#{field}:"#{params[:query]}") }.join(' OR ')})) if params[:query].present?
        api_query << %(price:[#{params[:min_price].presence || '*'} TO #{params[:max_price].presence || '*'}])  if params[:min_price].present? || params[:max_price].present?
        api_query << %(categoryId:(#{params[:category_ids].join(' ')}))                                         if params[:category_ids].present?
        api_query << %(merchantId:"#{params[:merchant_id]}")                                                    if params[:merchant_id].present?
        api_query << %(country:"#{params[:locale]}")                                                            if params[:locale].present?

        # TODO: Check for categoryId 0, '' or nil, missing categoryId

        query_params = {
          :q => CGI.escape(api_query.join(' AND '))
        }
        query_params[:rows]  = params[:rows]  if params[:rows].present?
        query_params[:start] = params[:start] if params[:start].present?

        product_api('query', query_params)['skimlinksProductAPI']
      end
    end

    def product_count(params)
      product_search(params.merge(:rows => 0)).first
    end

    def product_categories
      product_api('categories')['skimlinksProductAPI']['categories']
    end

    def merchant_categories
      merchant_api 'categories'
    end

    def merchant_category_ids
      flatten(self.merchant_categories).grep(/^\d+$/).uniq.map(&:to_i)
    end

    def merchants(category_id, locale, exclude_no_products)
      [].tap do |merchants|
        start, found = 0, nil

        while found.nil? || start < found
          data = merchant_api('category', category_id, 'limit', 200, 'start', start)

          # Filter by locale
          if locale.present?
            data['merchants'].reject! do |merchant|
              merchant['countries'].present? && (LocaleMerchantCountries[locale.to_sym] & merchant['countries']).empty?
            end
          end

          # Add product count for each merchant
          data['merchants'].each do |merchant|
            merchant.merge! 'productCount' => self.product_count(:merchant_id => merchant['merchantID'])
          end

          # Exclude merchants without any products
          if exclude_no_products
            data['merchants'].reject! do |merchant|
              merchant['productCount'] == 0
            end
          end

          merchants << data['merchants']

          start = data['numStarted'].to_i + data['numReturned'].to_i
          found = data['numFound']
        end
      end.flatten
    end

    def affiliate(url, publisher_id)
      link_api url, publisher_id
    end

    private

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

    def returning_count_and_products(&block)
      result = block.call
      [result['numFound'], result['products']]
    end

    def product_api(method, params = {})
      query_params = DefaultParams[:product_api].merge(params).reverse_merge(:key => Skimlinks.configuration.api_key)

      raise Skimlinks::ApiError, 'API key not configured' if query_params[:key].blank?

      path = [method, URI.encode_www_form(query_params)].join('?')

      returning_json do
        @product_api[path].get
      end
    end

    def merchant_api(method, *params)
      raise Skimlinks::ApiError, 'API key not configured' if Skimlinks.configuration.api_key.blank?

      returning_json do
        path = [
          DefaultParams[:merchant_api][:format],
          Skimlinks.configuration.api_key,
          method,
          *params
        ].join('/')

        @merchant_api[path].get
      end
    end

    def link_api(url, publisher_id)
      query_params = DefaultParams[:link_api].merge(:url => CGI.escape(url), :id => publisher_id)
      path         = [Endpoints[:link_api], URI.encode_www_form(params)].join('?')
      response     = @mechanize.head(path)

      raise StandardError, "Unexpected response code: #{response.code}" unless response.code == '302'

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
