require "muskrat"
require "muskrat/configurer"
require "muskrat/refinements/hash_refinements"

using HashRefinements

module Muskrat
  module Subscriber
    TOPIC_NOT_SPECIFIED = "%{klass} not subscribed to any topic.".freeze

    module ClassMethods
      def publish(*args)
        # TODO:
        # Also make available a normal publish api
        # @@topic set when subscriber loads

        Muskrat::Mqtt.with_client do |client|
          publisher = Muskrat::Mqtt::Publisher.any(@@topic)
          client.publish(publisher.topic, args, publisher.retain)
        end
      end

      def subscribe(*args)
        @@topic = args.first&.[](:topic) || args.first&.[]("topic")
        raise TOPIC_NOT_SPECIFIED % {klass: name} unless @@topic

        Muskrat.options.merge!(
          Muskrat::Configurer.reconcile_subscription(
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
