module Skimlinks
  class Configuration
    VALID_CONFIG_KEYS = [
      :api_key,
      :format
    ].freeze

    DEFAULT_API_KEY = nil
    DEFAULT_FORMAT  = :json

    attr_accessor *VALID_CONFIG_KEYS

    def initialize
      self.reset
    end

    def options
      Hash[*VALID_CONFIG_KEYS.map { |key| [key, self.send(key)] }.flatten]
    end

    def reset
      VALID_CONFIG_KEYS.each do |key|
        self.send "#{key}=", self.class.const_get("DEFAULT_#{key.to_s.upcase}")
      end
    end
  end
end
