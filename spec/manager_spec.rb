require 'muskrat'
require 'muskrat/manager'

require 'pry-byebug'

describe 'Muskrat::Manager' do
  before :all do
    config_file_path = File.join(File.expand_path('../', __FILE__), 'support/config.yml')
    configurer = Muskrat::Configuration::Loader.new(Muskrat.options)
    configurer.config_file = config_file_path

    require_relative "./support/sample_subscribers/notification_subscriber"
    require_relative "./support/sample_subscribers/heartbeart_subscriber"
  end

  after(:all) do
    ($LOADED_FEATURES.grep /sample_subscribers/).each do |path|
      $LOADED_FEATURES.delete(path)
    end
  end

  before(:each) do
    allow(Muskrat.env).to receive(:env_str).and_return('production')
  end

  describe '.new' do
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
  end
end
