require "muskrat"
require "muskrat/configuration"
require_relative '../refinements/refined_hash'
using RefinedHash

module Muskrat
  module Subscriber
    TOPIC_NOT_SPECIFIED = "%{klass} not subscribed to any topic.".freeze

    module ClassMethods
      def subscribe(*args)
        @@topic = args.first&.[](:topic) || args.first&.[]("topic")
        raise TOPIC_NOT_SPECIFIED % {klass: name} unless @@topic

        Muskrat.options.merge!(
          Muskrat::Configuration.reconcile_subscription(
            Muskrat.options,
            {subscriber: name}.merge(args.first.symbolize_keys)
          )
        )
      end
    end

    def self.included(base)
      base.extend(ClassMethods)
    end
  end
end
