require 'muskrat'
require 'muskrat/client'
require 'muskrat/configurer'

module Muskrat
  module Subscriber
    TOPIC_NOT_SPECIFIED='%{klass} not subscribed to any topic.'.freeze

    module ClassMethods
      def publish(*args)
      end

      def subscribe(*args)
        topic = args.first&.[](:topic) || args.first&.[]("topic")

        raise TOPIC_NOT_SPECIFIED % {klass: self.name} unless topic

        Muskrat.options.merge!(
          Muskrat::Configurer.reconcile_subscription(
            Muskrat.options,
            { subscriber: self.name, topic: topic }
          )
        )
      end
    end

    def self.included(base)
      base.extend(ClassMethods)
    end
  end
end
