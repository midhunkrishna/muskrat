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

    def stop
      ##
      # TODO:
      # - Wait for 30 seconds for #stop to return
      # - Dump job args into storage if thread busy
      #    and ard kill after 30 seconds
      @handlers.map(&:stop)
    end

    def pause
      ##
      # TODO:
      # pause subscription handlers
      # - workers should pause reading from read queue
      # - andler should stop reading from socket
    end

    def resume
      ##
      # TODO:
      # resume normal operation of subscription handlers
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
