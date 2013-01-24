require 'spec_helper'

describe Skimlinks::ProductSearch do
  subject { Skimlinks::ProductSearch.new }

  before do
    Skimlinks.configuration.api_key = '85399dc089e6baf58e1d664670f4614e'
  end

  describe '#categories' do
    it 'returns a hash' do
      VCR.use_cassette 'Skimlinks_ProductSearch' do
        subject.categories.should be_an_instance_of(Hash)
      end
    end
  end

  describe '#nested_categories' do
    it 'returns a hash' do
      VCR.use_cassette 'Skimlinks_ProductSearch' do
        subject.nested_categories.should be_an_instance_of(Hash)
      end
    end
  end

  describe '#products' do
    let(:products) { subject.products(query: 'justin bieber') }

    it 'returns an array of Skimlinks::Product objects' do
      VCR.use_cassette 'Skimlinks_ProductSearch' do
        products.should be_an_instance_of(Array)
        products.should be_all { |product| product.is_a?(Skimlinks::Product) }
      end
    end
  end

  describe '#product_count' do
    it 'returns an integer' do
      VCR.use_cassette 'Skimlinks_ProductSearch' do
        subject.product_count(query: 'justin bieber').should be_an_instance_of(Fixnum)
      end
    end
  end
end
