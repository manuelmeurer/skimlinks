require 'spec_helper'

describe Skimlinks::MerchantSearch do
  use_vcr_cassette

  before do
    Skimlinks.configuration.api_key = 'foo'
  end

  describe '#merchants_in_category' do
    it 'returns an array' do
      Skimlinks::MerchantSearch.new.merchants_in_category(1).should be_an_instance_of(Array)
    end
  end

  describe '#merchants' do
    it 'returns an array' do
      Skimlinks::MerchantSearch.new.merchants.should be_an_instance_of(Array)
    end
  end
end
