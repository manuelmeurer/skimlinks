require 'spec_helper'

describe Skimlinks::MerchantApi do
  before do
    Skimlinks.configuration.api_key = 'foo'
  end

  describe '#categories' do
    it 'returns a hash' do
      VCR.use_cassette 'Skimlinks_MerchantApi' do
        Skimlinks::MerchantApi.categories.should be_an_instance_of(Hash)
      end
    end
  end

  describe '#nested_categories' do
    it 'returns a hash' do
      VCR.use_cassette 'Skimlinks_MerchantApi' do
        Skimlinks::MerchantApi.nested_categories.should be_an_instance_of(Hash)
      end
    end
  end

  describe '#merchants' do
    it 'returns an array of Skimlinks::Merchant objects' do
      VCR.use_cassette 'Skimlinks_MerchantApi' do
        merchants = Skimlinks::MerchantApi.merchants
        merchants.should be_an_instance_of(Array)
        merchants.should be_all { |merchant| merchant.is_a?(Skimlinks::Merchant) }
      end
    end
  end

  describe '#merchant' do
    it 'returns a Skimlinks::Merchant' do
      VCR.use_cassette 'Skimlinks_MerchantApi' do
        Skimlinks::MerchantApi.merchant(12678).should be_an_instance_of(Skimlinks::Merchant)
      end
    end
  end
end
