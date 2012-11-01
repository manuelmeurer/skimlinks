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
  valid_values_const_name = "VALID_#{key.to_s.pluralize.upcase}"
  if Skimlinks::Configuration.const_defined?(valid_values_const_name)
    valid_values = Skimlinks::Configuration.const_get(valid_values_const_name)
    if valid_values == Fixnum
      rand(1_000)
    elsif valid_values.is_a?(Array)
      Skimlinks::Configuration.const_get(valid_values_const_name).sample
    else
      raise StandardError, "Unexpected #{valid_values_const_name} type: #{valid_values}"
    end
  else
    Faker::Lorem.word
  end
end
