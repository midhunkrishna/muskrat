require_relative '../spec_helper'

require 'muskrat'
require 'muskrat/publisher'

describe 'Muskrat::Publisher' do
  before(:each) do
    @require_stack = []
  end

  after(:each) do
    @require_stack.each do | path_partial |
      $LOADED_FEATURES.reject! { |path| path =~ Regexp.new(path_partial) }
    end
  end

  def recorded_require(path_partial)
    @require_stack.push(path_partial)
    require_relative "../support/#{path_partial}"
  end

  class TestPublisher
    include Muskrat::Publisher
  end

  describe '.publish' do
    before(:each) do
      @client_double = double(:mqtt_client)
    end

    it 'logs when the published topic is not subscribed by any muskrat subscribers' do
      recorded_require 'sample_subscribers/multi_subscriber'

      expect(Muskrat::Mqtt).to receive(:with_client).and_yield(@client_double)
      expect(@client_double).to receive(:publish)
        .with(
          "random_events",
          Muskrat.dump_json({:device_up=>true}),
          false
        )

      expect(Muskrat::Logger).to receive(:log).with(Muskrat::Publisher::SUBSCRIBER_NOT_FOUND)
      TestPublisher.publish('random_events', {device_up: true})
    end

    it 'dispatches args to specified topic, with default retain level' do
      recorded_require 'sample_subscribers/multi_subscriber'

      expect(Muskrat::Mqtt).to receive(:with_client).and_yield(@client_double)
      expect(@client_double).to receive(:publish)
        .with(
          "events/#",
          Muskrat.dump_json({:device_up=>true}),
          false
        )

      TestPublisher.publish('events/#', {device_up: true})
    end
  end
end
