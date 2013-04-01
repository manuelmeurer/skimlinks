require 'skimlinks'
require 'webmock/rspec'
require 'vcr'
require 'ffaker'

VCR.configure do |config|
  config.hook_into :webmock
  config.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  config.default_cassette_options = {
    allow_playback_repeats: true,
    match_requests_on: [:method, VCR.request_matchers.uri_without_param(:key)]
  }
end

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = 'random'
end
