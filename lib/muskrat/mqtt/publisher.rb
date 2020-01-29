module Muskrat
  module Mqtt
    class Publisher

      def self.any(topic)
        new subscriber_configs(topic).sample
      end

      def self.of(topic)
        subscriber_configs(topic).each do |subscriber_config|
          new subscriber_config
        end
      end

      def initialize(config)
        @config = config
      end

      private

      def subscriber_configs(topic)
        Muskrat.options[:subscriber_config][topic.to_sym]
      end

      def klass
        @config[:klass]
      end

      def topic
        @config[:topic]
      end

      def retain
        @config[:retain]
      end
    end
  end
end
