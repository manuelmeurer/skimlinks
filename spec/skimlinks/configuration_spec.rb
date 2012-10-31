require 'spec_helper'

describe Skimlinks::Configuration do
  before do
    Skimlinks.configuration.reset
  end

  describe '.configure' do
    Skimlinks::Configuration::VALID_CONFIG_KEYS.each do |key|
      it "should set the #{key}" do
        Skimlinks.configure do |config|
          config.send "#{key}=", key
        end
        Skimlinks.configuration.send(key).should eq(key)
      end
    end
  end

  Skimlinks::Configuration::VALID_CONFIG_KEYS.each do |key|
    describe "##{key}" do
      it 'should return the default value' do
        Skimlinks.configuration.send(key).should eq(Skimlinks::Configuration.const_get("DEFAULT_#{key.upcase}"))
      end
    end
  end
end
