require 'spec_helper'

describe Skimlinks::ProductSearch do
  use_vcr_cassette

  before do
    Skimlinks.configuration.api_key = 'foo'
  end

  describe '#category_list' do
    it 'returns a hash' do
      Skimlinks::ProductSearch.category_list.should be_an_instance_of(Hash)
    end
  end
end
