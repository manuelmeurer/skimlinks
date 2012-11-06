require 'skimlinks'
require 'webmock/rspec'
require 'vcr'
require 'ffaker'

VCR.configure do |config|
  config.hook_into :webmock
  config.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  config.default_cassette_options = {
    record:            :new_episodes,
    match_requests_on: [:method, VCR.request_matchers.uri_without_param(:key)]
  }
end

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus

  config.order = 'random'

  # Make VCR macros available to all specs
  config.extend VCR::RSpec::Macros
end

def valid_value_for_config(key)
  valid_values_const_name        = "VALID_#{key.to_s.pluralize.upcase}"
  valid_value_classes_const_name = "VALID_#{key.to_s.upcase}_CLASSES"
  case
  when Skimlinks::Configuration.const_defined?(valid_values_const_name)
    valid_values = Skimlinks::Configuration.const_get(valid_values_const_name)
    raise StandardError, "#{valid_values_const_name} should be an array." unless valid_values.is_a?(Array)
    valid_values.sample
  when Skimlinks::Configuration.const_defined?(valid_value_classes_const_name)
    valid_value_classes = Skimlinks::Configuration.const_get(valid_value_classes_const_name)
    raise StandardError, "#{valid_value_classes_const_name} should be an array of classes." unless valid_value_classes.is_a?(Array) && valid_value_classes.each { |klass| klass.is_a?(Class) }
    case
    when valid_value_classes.include?(NilClass)
      nil
    when valid_value_classes.include?(Fixnum)
      rand(1_000)
    else
      raise StandardError, "Don't know how to create valid value for config #{key}."
    end
  else
    Faker::Lorem.word
  end
end
