require 'spec_helper'

describe Skimlinks::Client do
  describe 'with module configuration' do
    [:module_config, :class_config].each do |config|
      let(config) {
        Hash[
          *Skimlinks::Configuration::VALID_CONFIG_KEYS.map { |key| [key, valid_value_for_config(key)] }.flatten
        ]
      }
    end

    before do
      Skimlinks.configure do |config|
        Skimlinks::Configuration::VALID_CONFIG_KEYS.each do |key|
          config.send "#{key}=", module_config[key]
        end
      end
    end

    it 'should inherit module configuration' do
      client = Skimlinks::Client.new

      Skimlinks::Configuration::VALID_CONFIG_KEYS.each do |key|
        client.send(key).should eq(module_config[key])
      end
    end

    describe 'with class configuration' do
      it 'should override module configuration' do
        client = Skimlinks::Client.new(class_config)

        Skimlinks::Configuration::VALID_CONFIG_KEYS.each do |key|
          client.send(key).should eq(class_config[key])
        end
      end

      it 'should override module configuration after' do
        client = Skimlinks::Client.new

        class_config.each do |key, value|
          client.send "#{key}=", value
        end

        Skimlinks::Configuration::VALID_CONFIG_KEYS.each do |key|
          client.send(key).should eq(class_config[key])
        end
      end
    end
  end
end
