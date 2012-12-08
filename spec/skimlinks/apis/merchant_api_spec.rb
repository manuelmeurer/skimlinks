require 'spec_helper'

describe Skimlinks::MerchantApi do
  use_vcr_cassette

  before do
    Skimlinks.configuration.api_key = 'foo'
  end

  describe '#categories' do
    it 'returns a hash' do
      Skimlinks::MerchantApi.categories.should be_an_instance_of(Hash)
    end
  end

  describe '#nested_categories' do
    it 'returns a hash' do
      Skimlinks::MerchantApi.nested_categories.should be_an_instance_of(Hash)
    end
  end

  describe '#merchants' do
    it 'returns an array of Skimlinks::Merchant objects' do
      merchants = Skimlinks::MerchantApi.merchants
      merchants.should be_an_instance_of(Array)
      merchants.should be_all { |merchant| merchant.is_a?(Skimlinks::Merchant) }
    end
  end

  describe '#merchant' do
    it 'returns a Skimlinks::Merchant' do
      Skimlinks::MerchantApi.merchant(12678).should be_an_instance_of(Skimlinks::Merchant)
    end
  end
end
