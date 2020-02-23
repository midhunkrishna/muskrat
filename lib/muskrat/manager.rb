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
          subscription_configurations(channel),
          mqtt_configurations
        )
      end
    end

    def env_configuration
      @_env_configuration ||= @options[:config][Muskrat.env.env_str.to_sym]
    end

    def subscription_configurations(channel)
      env_configuration[:subscriptions].detect {|config| config[:name].to_sym == channel }
    end

    def mqtt_configurations
      env_configuration[:mqtt]
    end
  end
end
