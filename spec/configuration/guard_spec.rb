require_relative '../spec_helper'
require 'muskrat'
require 'muskrat/configuration'

describe 'Muskrat::Configuration::Guard' do
  def subject(config)
    Muskrat::Configuration::Guard.new(config).verify!
  end

  describe '#verify!' do
    it 'expects that config should have current env name under it' do
      expect {
        subject({})
      }.to raise_error(
        Muskrat::Configuration::LoadError,
        'Configuration not under environment. Please check sample configurations.'
      )
    end

    it "expects that current env should have details on concurrency" do
      expect {
        subject(
          {
            production: {
              concurrency: "10"
            }
          }
        )
      }.to raise_error(
        Muskrat::Configuration::LoadError,
        'Please configure values for concurrency, subscriptions, mqtt. Please check sample configurations.'
      )
    end

    it "expects that current env should have details on subscriptions" do
      expect {
        subject(
          {
            production: {
              concurrency: 10,
              subscriptions: []
            }
          }
        )
      }.to raise_error(
        Muskrat::Configuration::LoadError,
        'Please configure values for concurrency, subscriptions, mqtt. Please check sample configurations.'
      )
    end

    it "expects that current env should have details on mqtt" do
      expect {
        subject(
          {
            production: {
              concurrency: 10,
              subscriptions: [
                {
                  name: 'notifications',
                  ratio: 10
                }
              ]
            }
          }
        )
      }.to raise_error(
        Muskrat::Configuration::LoadError,
        'Please configure values for concurrency, subscriptions, mqtt. Please check sample configurations.'
      )
    end

    it 'expects that mqtt to have host entry' do
      expect {
        subject(
          {
            production: {
              concurrency: 10,
              subscriptions: [
                {
                  name: 'notifications',
                  ratio: 10
                }
              ],
              mqtt: {}
            }
          }
        )
      }.to raise_error(
        Muskrat::Configuration::LoadError,
        'Muskrat cannot run without an mqtt endpoint. Please check sample configurations Please check sample configurations.'
      )
    end

    it 'verifies that the configuration is correct' do
      config_path =  File.join(File.expand_path('../../', __FILE__), 'support/config.yml')
      expect {
        subject(YAML.load(File.read(config_path)))
      }.not_to raise_error
    end
  end
end
