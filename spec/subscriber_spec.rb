require_relative 'spec_helper'
require 'muskrat/subscriber'
require 'pry-byebug'

describe 'Muskrat::Subscriber' do
  before(:each) do
    @require_stack = []
    @muskrat_options = Muskrat.options
    Muskrat.instance_variable_set(:@options, Muskrat::DEFAULTS.dup)
  end

  after(:each) do
    Muskrat.instance_variable_set(:@options, @muskrat_options)
    @require_stack.each do | path_partial |
      $LOADED_FEATURES.reject! { |path| path =~ Regexp.new(path_partial) }
    end
  end

  def recorded_require(path_partial)
    @require_stack.push(path_partial)
    require_relative "./support/#{path_partial}"
  end

  describe ".publish" do
    Muskrat.configure do |config|
      config.config_file = File.join(File.expand_path('../', __FILE__), 'support/config.yml')
    end

    # TODO
    # implement configurer guard first
  end

  describe ".subscribe" do
    it 'sets subscription information in :subscriber_config' do
      recorded_require 'sample_subscribers/notification_subscriber'
      expect(Muskrat.options[:subscriber_config]).
        to eq(
          {
            notifications: [
              {
                :klass=>"NotificationSubscriber",
                :topic=>"notifications"
              }
            ]
          }
        )

      recorded_require 'sample_subscribers/event_subscriber'

      expect(Muskrat.options[:subscriber_config]).
        to eq({
          :notifications => [
            {
              :klass =>"NotificationSubscriber",
              :topic =>"notifications"
            }
          ],
          "events/#".to_sym => [
            {
              :klass =>"EventSubscriber",
              :topic => "events/#"
            }
          ]
        })
    end

    it 'reconciles same topic subscriptions on different workers' do
      recorded_require 'sample_subscribers/event_subscriber'
      expect(Muskrat.options[:subscriber_config]).
        to eq({
          "events/#".to_sym => [
            {
              :klass=>"EventSubscriber",
              :topic=> "events/#"
            }
          ]
        })

      recorded_require 'sample_subscribers/secondary_event_subscriber'
      expect(Muskrat.options[:subscriber_config]).
        to eq({
          "events/#".to_sym => [
            {
              :klass=>"EventSubscriber",
              :topic=> "events/#"
            },
            {
              :klass=>"SecondaryEventSubscriber",
              :topic=> "events/#"
            }
          ]
        })
    end

    it 'raises exception when topic is not specified' do
      expect {
        recorded_require 'sample_subscribers/no_topic_subscriber'
      }.to raise_exception(
        RuntimeError, Muskrat::Subscriber::TOPIC_NOT_SPECIFIED % {klass: 'NoTopicSubscriber'}
      )
    end

    it 'can configure multiple subscriptions' do
      recorded_require 'sample_subscribers/multi_subscriber'

      expect(Muskrat.options[:subscriber_config]).
        to eq({
          "events/#".to_sym => [
            {
              :klass => "MultiSubscriber",
              :topic=> "events/#"
            }
          ],
          :notifications => [
            {
              :klass => "MultiSubscriber",
              :topic=> "notifications"
            }
          ],
          :alarms => [
            {
              :klass => "MultiSubscriber",
              :topic=> "alarms"
            }
          ]
        })
    end
  end
end
