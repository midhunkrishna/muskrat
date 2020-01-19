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

  it 'sets subscription information in :subscriber_config' do
    recorded_require 'sample_subscribers/notification_subscriber'
    expect(Muskrat.options[:subscriber_config]).
      to eq({ notifications: [{:klass=>"NotificationSubscriber"}] } )

    recorded_require 'sample_subscribers/event_subscriber'

    expect(Muskrat.options[:subscriber_config]).
      to eq({
        :notifications => [
          {
            :klass=>"NotificationSubscriber"
          }
        ],
        "events/#".to_sym => [
          {
            :klass=>"EventSubscriber"
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
            :klass=>"EventSubscriber"
          }
        ]
      })

    recorded_require 'sample_subscribers/secondary_event_subscriber'
    expect(Muskrat.options[:subscriber_config]).
      to eq({
        "events/#".to_sym => [
          {
            :klass=>"EventSubscriber"
          },
          {
            :klass=>"SecondaryEventSubscriber"
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
            :klass => "MultiSubscriber"
          }
        ],
        :notifications => [
          {
            :klass => "MultiSubscriber"
          }
        ],
        :alarms => [
          {
            :klass => "MultiSubscriber"
          }
        ]
      })
  end
end
