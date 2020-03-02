require 'muskrat'
require 'muskrat/subscription_handler'

module Muskrat
  class Manager
    def initialize(options)
      @options = options
      @handlers = subscription_handlers
      # subscription_handlers
      #
    end

    def run
      # call start on subscription handlers
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
      total_ratio = subscriptions.map{ | sub | sub[:ratio].to_i }.sum
      subscription = subscriptions.detect { | sub | sub[:name] == channel }

      (total_worker_concurrency / total_ratio) * subscription[:ratio]
    end
  end
end
