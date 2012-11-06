require 'active_support/core_ext/string'
require 'active_support/core_ext/numeric'

module Skimlinks
  class Configuration
    VALID_CONFIG_KEYS = [
      :api_key,
      :format,
      :cache,
      :cache_ttl
    ]

    VALID_FORMATS = [
      :xml,
      :json
    ]

    DEFAULT_API_KEY    = nil
    DEFAULT_FORMAT     = :json
    DEFAULT_CACHE      = nil
    DEFAULT_CACHE_TTL  = 1.day

    attr_accessor *VALID_CONFIG_KEYS

    def initialize
      self.reset
    end

    def options
      Hash[*VALID_CONFIG_KEYS.map { |key| [key, self.send(key)] }.flatten]
    end

    def reset
      VALID_CONFIG_KEYS.each do |key|
        self.send "#{key}=", self.class.const_get("DEFAULT_#{key.upcase}")
      end
    end

    VALID_CONFIG_KEYS.each do |key|
      valid_values_const_name = "VALID_#{key.to_s.pluralize.upcase}"
      if self.const_defined?(valid_values_const_name)
        valid_values = self.const_get(valid_values_const_name)
        define_method "#{key}=" do |value|
          if valid_values.is_a?(Class)
            raise ArgumentError, "#{value} is not a valid value for #{key}. Valid values must be a #{valid_values}." unless value.is_a?(valid_values)
          else
            raise ArgumentError, "#{value} is not a valid value for #{key}. Valid values are: #{valid_values.join(', ')}" unless valid_values.include?(value)
          end

          self.instance_variable_set "@#{key}", value
        end
      end
    end
  end
end
