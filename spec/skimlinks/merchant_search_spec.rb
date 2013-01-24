require 'spec_helper'

describe Skimlinks::MerchantSearch do
  subject { Skimlinks::MerchantSearch.new }

  before do
    Skimlinks.configuration.api_key = 'foo'
  end

  describe '#categories' do
    it 'returns a hash' do
      VCR.use_cassette 'Skimlinks_MerchantSearch' do
        subject.categories.should be_an_instance_of(Hash)
      end
    end
  end

  describe '#nested_categories' do
    it 'returns a hash' do
      VCR.use_cassette 'Skimlinks_MerchantSearch' do
        subject.nested_categories.should be_an_instance_of(Hash)
      end
    end
  end

  describe '#merchants' do
    let(:merchants) { subject.merchants }

    it 'returns an array of Skimlinks::Merchant objects' do
      VCR.use_cassette 'Skimlinks_MerchantSearch' do
        merchants.should be_an_instance_of(Array)
        merchants.should be_all { |merchant| merchant.is_a?(Skimlinks::Merchant) }
      end
    end
  end

  describe '#merchant' do
    it 'returns a Skimlinks::Merchant' do
      VCR.use_cassette 'Skimlinks_MerchantSearch' do
        subject.merchant(12678).should be_an_instance_of(Skimlinks::Merchant)
      end
    end
  end
end
