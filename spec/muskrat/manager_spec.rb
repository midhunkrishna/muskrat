require 'muskrat'
require 'muskrat/manager'

require 'pry-byebug'

describe 'Muskrat::Manager' do
  before :all do
    config_file_path = File.join(File.expand_path('../../', __FILE__), 'support/config.yml')
    configurer = Muskrat::Configuration::Loader.new(Muskrat.options)
    configurer.config_file = config_file_path

    require_relative "../support/sample_subscribers/notification_subscriber"
    require_relative "../support/sample_subscribers/heartbeart_subscriber"
  end

  after(:all) do
    ($LOADED_FEATURES.grep /sample_subscribers/).each do |path|
      $LOADED_FEATURES.delete(path)
    end
  end

  before(:each) do
    allow(Muskrat.env).to receive(:env_str).and_return('production')
  end

  describe 'initialize' do
    it 'instantiates and collects subscription handler classes' do
      expect(Muskrat::SubscriptionHandler).
        to receive(:new).
        with(
          :notifications,
          array_including({:klass=> "NotificationSubscriber", :topic=> "notifications"}),
          5
        )

      expect(Muskrat::SubscriptionHandler).
        to receive(:new).
        with(
          :"heartbeat/#",
          array_including({:klass=> "HeartbeatSubscriber", :topic=> "heartbeat/#"}),
         5
        )

      Muskrat::Manager.new(Muskrat.options)
    end

    it 'assigns a single worker to a channel if config doesnt specify one' do
      require_relative "../support/sample_subscribers/multi_subscriber"
      handlers = Muskrat::Manager.new(Muskrat.options).handlers

      events_handler = handlers.detect { |h| h.instance_variable_get(:@channel) == "events/#" }
      alarms_handler = handlers.detect { |h| h.instance_variable_get(:@channel) == "alarms" }

      expect(events_handler.instance_variable_get(:@worker_count)).to eq 1
      expect(alarms_handler.instance_variable_get(:@worker_count)).to eq 1
    end
  end

  describe '#run' do
    it 'calls start on all subscription handlers' do
      # expect_any_instance_of(Muskrat::SubscriptionHandler).to receive(:start).twice
      manager = Muskrat::Manager.new(Muskrat.options)

      manager.handlers.each do |handler|
        expect(handler).to receive(:start)
      end

      manager.run
    end
  end
end
