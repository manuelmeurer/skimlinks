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
    let(:category_id) { 12 }
    let(:query) { 'amazon' }

    it 'returns an array of Skimlinks::Merchant objects' do
      VCR.use_cassette 'Skimlinks_MerchantSearch' do
        subject.merchants.should be_an_instance_of(Array)
        subject.merchants.should be_present
        subject.merchants.should be_all { |merchant| merchant.is_a?(Skimlinks::Merchant) }
      end
    end

    context 'when searching by a category ID' do
      let(:merchants) { subject.merchants(category_ids: category_id) }

      it 'returns merchants from the specified category' do
        VCR.use_cassette 'Skimlinks_MerchantSearch' do
          merchants.should be_an_instance_of(Array)
          merchants.should be_present
          merchants.should be_all { |merchant| merchant.categories.keys.map(&:to_i).include?(category_id) }
        end
      end
    end

    context 'when searching by a query' do
      let(:merchants) { subject.merchants(query: query) }

      it 'returns merchants that match the query' do
        VCR.use_cassette 'Skimlinks_MerchantSearch' do
          merchants.should be_all { |merchant| merchant.name =~ /#{Regexp.escape(query)}/i }
        end
      end
    end

    context 'when searching by a category ID and a query' do
      let(:merchants) { subject.merchants(category_ids: category_id, query: query) }

      it 'returns merchants that match the query' do
        VCR.use_cassette 'Skimlinks_MerchantSearch' do
          merchants.should be_all { |merchant| merchant.categories.keys.map(&:to_i).include?(category_id) && merchant.name =~ /#{Regexp.escape(query)}/i }
        end
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
