require 'spec_helper'

describe Skimlinks::Client do
  context 'configuration' do
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

      it 'inherits module configuration' do
        client = Skimlinks::Client.new

        Skimlinks::Configuration::VALID_CONFIG_KEYS.each do |key|
          client.send(key).should eq(module_config[key])
        end
      end

      describe 'with class configuration' do
        it 'overrides module configuration' do
          client = Skimlinks::Client.new(class_config)

          Skimlinks::Configuration::VALID_CONFIG_KEYS.each do |key|
            client.send(key).should eq(class_config[key])
          end
        end

        it 'overrides module configuration after' do
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

  context 'actions' do
    use_vcr_cassette 'Skimlinks_Client'

    before do
      Skimlinks.configuration.api_key = 'foo'
    end

    describe '#merchant_categories' do
      subject { Skimlinks::Client.new.merchant_categories }

      it 'returns a non-empty hash' do
        subject.should be_an_instance_of(Hash)
        subject.should_not be_empty
      end
    end

    describe '#merchant_category_ids' do
      subject { Skimlinks::Client.new.merchant_category_ids }

      it 'returns a non-empty array' do
        subject.should be_an_instance_of(Array)
        subject.should_not be_empty
      end
    end
  end
end
