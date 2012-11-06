require 'active_support/core_ext/string'
require 'active_support/core_ext/numeric'
require 'active_support/cache'

module Skimlinks
  class Configuration
    VALID_CONFIG_KEYS = [
      :api_key,
      :format,
      :cache,
      :cache_ttl
    ]

    VALID_FORMATS = [
      # :xml, # TODO: Enable this when XML is supported
      :json
    ]
    VALID_CACHE_CLASSES = [
      NilClass,
      ActiveSupport::Cache::Store
    ]
    VALID_CACHE_TTL_CLASSES = [
      Fixnum
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
      valid_values_const_name        = "VALID_#{key.to_s.pluralize.upcase}"
      valid_value_classes_const_name = "VALID_#{key.to_s.upcase}_CLASSES"
      case
      when self.const_defined?(valid_values_const_name)
        valid_values = self.const_get(valid_values_const_name)
        raise StandardError, "#{valid_values_const_name} should be an array." unless valid_values.is_a?(Array)
        define_method "#{key}=" do |value|
          raise ArgumentError, "#{value} is not a valid value for #{key}. Valid values are: #{valid_values.join(', ')}" unless valid_values.include?(value)
          self.instance_variable_set "@#{key}", value
        end
      when self.const_defined?(valid_value_classes_const_name)
        valid_value_classes = self.const_get(valid_value_classes_const_name)
        raise StandardError, "#{valid_value_classes_const_name} should be an array of classes." unless valid_value_classes.is_a?(Array) && valid_value_classes.each { |klass| klass.is_a?(Class) }
        define_method "#{key}=" do |value|
          raise ArgumentError, "#{value} is not a valid value for #{key}. Valid values classes are: #{valid_value_classes.join(', ')}" unless valid_value_classes.any? { |klass| value.class <= klass }
          self.instance_variable_set "@#{key}", value
        end
      end
    end
  end
end
