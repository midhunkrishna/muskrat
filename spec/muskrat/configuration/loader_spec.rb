require_relative '../../spec_helper'
require 'muskrat'
require 'muskrat/configuration'

describe 'Muskrat::Configuration::Loader' do
  before(:each) do
    @config_file_path = File.join(File.expand_path('../../../', __FILE__), 'support/config.yml')
    @muskrat_options = Muskrat.options
    Muskrat.instance_variable_set(:@options, Muskrat::DEFAULTS.dup)
  end

  after(:each) do
    Muskrat.instance_variable_set(:@options, @muskrat_options)
  end

  it 'responds to parse_and_load_config' do
    configurer = Muskrat::Configuration::Loader.new({})
    expect(configurer).to respond_to(:parse_and_load_config)
  end

  describe '#config_file=' do
    it 'updates Muskrat.options with config_file' do
      configurer = Muskrat::Configuration::Loader.new(Muskrat.options)
      allow(configurer).to receive(:load_config)
      configurer.config_file = @config_file_path
      expect(Muskrat.options[:config_file]).to eq(@config_file_path)
    end

    it 'updates Muskrat.options with configuration' do
      expect(Muskrat.options[:config]).to be_nil
      configurer = Muskrat::Configuration::Loader.new(Muskrat.options)
      configurer.config_file=@config_file_path
      expect(Muskrat.options[:config]).not_to be_nil
    end

    it 'verifies the loaded configuration file using guard' do
      expect(Muskrat.options[:config]).to be_nil
      configurer = Muskrat::Configuration::Loader.new(Muskrat.options)

      expect_any_instance_of(Muskrat::Configuration::Guard).to receive(:verify!)
      configurer.config_file=@config_file_path
    end
  end
end
