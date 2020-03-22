require 'muskrat'
require 'muskrat/subscription_handler'

module Muskrat
  class Manager
    ON_SINGLE_THREAD = 1

    attr_reader :handlers

    def initialize(options)
      @options = options
      @handlers = subscription_handlers
    end

    def run
      @handlers.map(&:start)
    end


    private

    def subscription_handlers
      subscribers = Muskrat.options[:subscriber_config] || {}

      subscribers.map do |channel, subscriber_configurations|
        Muskrat::SubscriptionHandler.new(
          channel,
          subscriber_configurations,
          worker_count(channel)
        )
      end
    end

    def env_configuration
      @_env_configuration ||= @options[:config][Muskrat.env.env_str.to_sym]
    end

    def total_worker_concurrency
      env_configuration[:concurrency] || @options[:concurrency]
    end

    def worker_count(channel)
      subscriptions = env_configuration[:subscriptions]
      total_ratio = subscriptions.map{ | sub | sub[:ratio] || total_worker_concurrency}.sum

      subscription = subscriptions.detect do | sub |
        sub[:name] == channel || sub[:name] == channel.to_s
      end

      if subscription
        ((total_worker_concurrency / total_ratio.to_f) * subscription[:ratio]).to_i
      else
        ##
        # TODO:
        # Log warning ON_SINGLE_THREAD
        ON_SINGLE_THREAD
      end
    end
  end
end


=begin
require 'muskrat'
require 'muskrat/manager'
require_relative './spec/support/sample_subscribers/notification_subscriber'
config_file_path = File.join(File.expand_path('../spec', __FILE__), 'support/config.yml')
configurer = Muskrat::Configuration::Loader.new(Muskrat.options)
configurer.config_file = config_file_path

puts Muskrat.options
ENV['RAILS_ENV'] = 'production'

Muskrat::Manager.new(Muskrat.options)
=end
