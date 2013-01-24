module Skimlinks
  ApiError          = Class.new(StandardError)
  InvalidParameters = Class.new(StandardError)

  class << self
    def configure
      yield configuration
    end

    def configuration
      @configuration ||= Configuration.new
    end
  end
end

require 'skimlinks/version'
require 'skimlinks/configuration'
require 'skimlinks/client'
require 'skimlinks/merchant'
require 'skimlinks/product'
require 'skimlinks/search_helpers'
require 'skimlinks/merchant_search'
require 'skimlinks/product_search'
