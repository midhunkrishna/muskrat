require_relative 'spec_helper'
require 'muskrat'
require 'muskrat/configurer'

require 'pry-byebug'

describe 'Muskrat::Configurer' do
  before(:each) do
    @config_file_path = File.join(File.expand_path('../', __FILE__), 'support/config.yml')
    @muskrat_options = Muskrat.options
    Muskrat.instance_variable_set(:@options, Muskrat::DEFAULTS.dup)
  end

  after(:each) do
    Muskrat.instance_variable_set(:@options, @muskrat_options)
  end

  it 'responds to parse_and_load_config' do
    configurer = Muskrat::Configurer.new({})
    expect(configurer).to respond_to(:parse_and_load_config)
  end

  describe '#config_file=' do
    it 'updates Muskrat.options with config_file' do
      configurer = Muskrat::Configurer.new(Muskrat.options)
      allow(configurer).to receive(:load_config)
      configurer.config_file = @config_file_path
      expect(Muskrat.options[:config_file]).to eq(@config_file_path)
    end

    it 'updates Muskrat.options with configuration' do
      expect(Muskrat.options[:config]).to be_nil
      configurer = Muskrat::Configurer.new(Muskrat.options)
      configurer.config_file=@config_file_path
      expect(Muskrat.options[:config]).not_to be_nil
    end
  end

  describe '#guard' do
    it 'expects that config should have current env name under it' do
    end

    ['concurrency', 'subscriptions', 'mqtt'].each do | key |
      it "expects that current env should have details on #{key}" do
      end
    end

    it 'expects that concurrency value be integer' do
    end

    it 'expects that subscription is array of key value pairs' do
    end

    it 'expects that mqtt to have host entry' do
    end
  end
end
