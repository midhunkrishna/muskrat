require_relative '../../refinements/refined_hash'

using RefinedHash

module Muskrat
  module Configuration
    class Guard
      KEYS_UNDER_ENV = [:concurrency, :subscriptions, :mqtt]

      ERROR_MESSAGES = {
        has_environment: 'Configuration not under environment.',
        has_concurrency: 'Concurrency should be an integer value.',
        has_subscriptions: 'Subscriptions not a collection of key value pairs.',
        has_mqtt: 'Muskrat cannot run without an mqtt endpoint. Please check sample configurations',
        has_required_keys_under_environment: "Please configure values for #{KEYS_UNDER_ENV.join(', ')}."
      }.freeze

      def initialize(configuration)
        @configuration = configuration
      end

      def verify!
        assert_that(@configuration, :has_environment )
        under_environments do | env |
          assert_that(env, :has_required_keys_under_environment)
          assert_that(env, :has_concurrency)
          assert_that(env, :has_subscriptions)
          assert_that(env, :has_mqtt)
        end
      end


      private

      def under_environments &blk
        @configuration.each do |_, value|
          blk.call(value.symbolize_keys)
        end
      end

      def has_environment(config)
        config.all? { |_, config | config } && config.keys.any?
      end

      def has_required_keys_under_environment(config)
        (KEYS_UNDER_ENV - config.symbolize_keys.keys) == []
      end

      def has_concurrency(config)
        config.symbolize_keys[:concurrency].is_a?(Integer)
      end

      def has_subscriptions(config)
        config[:subscriptions].is_a?(Array) && config[:subscriptions].all? do | subscription |
          subscription.symbolize_keys[:name] && subscription.symbolize_keys[:ratio].is_a?(Integer)
        end
      end

      def has_mqtt(config)
        config[:mqtt].is_a?(Hash) && config[:mqtt].symbolize_keys[:host]
      end

      def assert_that(config, method)
        result = send(method, config)
        unless result
          raise LoadError, "#{ERROR_MESSAGES[method]} Please check sample configurations."
        end
      end
    end
  end
end
