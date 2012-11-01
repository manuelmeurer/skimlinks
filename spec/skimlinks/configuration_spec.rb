require 'spec_helper'

describe Skimlinks::Configuration do
  before do
    Skimlinks.configuration.reset
  end

  describe '.configure' do
    Skimlinks::Configuration::VALID_CONFIG_KEYS.each do |key|
      it "should set the #{key}" do
        valid_values_const_name = "VALID_#{key.to_s.pluralize.upcase}"
        value = if Skimlinks::Configuration.const_defined?(valid_values_const_name)
          Skimlinks::Configuration.const_get(valid_values_const_name).sample
        else
          Faker::Lorem.word
        end
        Skimlinks.configure do |config|
          config.send "#{key}=", value
        end
        Skimlinks.configuration.send(key).should eq(value)
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
