module Skimlinks
  class ApiError < StandardError; end

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
require 'skimlinks/api'
require 'skimlinks/merchant'
require 'skimlinks/merchant_search'
require 'skimlinks/product'
require 'skimlinks/product_search'
