require 'spec_helper'

describe Skimlinks::Configuration do
  before do
    Skimlinks.configuration.reset
  end

  describe '.configure' do
    Skimlinks::Configuration::VALID_CONFIG_KEYS.each do |key|
      it "sets the #{key}" do
        value = valid_value_for_config(key)
        Skimlinks.configure do |config|
          config.send "#{key}=", value
        end
        Skimlinks.configuration.send(key).should eq(value)
      end
    end
  end

  Skimlinks::Configuration::VALID_CONFIG_KEYS.each do |key|
    describe "##{key}" do
      it 'returns the default value' do
        Skimlinks.configuration.send(key).should eq(Skimlinks::Configuration.const_get("DEFAULT_#{key.upcase}"))
      end
    end
  end
end
