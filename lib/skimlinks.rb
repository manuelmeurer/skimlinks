require 'gem_config'
require 'active_support/cache'

module Skimlinks
  include GemConfig::Base

  ApiError          = Class.new(StandardError)
  InvalidParameters = Class.new(StandardError)

  with_configuration do
    has :api_key, classes: String
    has :format, values: :json, default: :json
    has :cache, classes: ActiveSupport::Cache::Store
    has :cache_ttl, classes: Numeric, default: 1.day
  end
end

require 'skimlinks/version'
require 'skimlinks/client'
require 'skimlinks/merchant'
require 'skimlinks/product'
require 'skimlinks/search_helpers'
require 'skimlinks/merchant_search'
require 'skimlinks/product_search'
