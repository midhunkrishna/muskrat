require "muskrat/refinements/hash_refinements"

using HashRefinements

module Muskrat
  module Mqtt
    class Client
      MANUAL_ATTRS=['cert_file', 'cert', 'key_file', 'key', 'ca_file']

      def initialize
        # TODO
        # Client to not start read thread in future

        @client = MQTT::Client.new(connection_config.except(MANUAL_ATTRS))
        MANUAL_ATTRS.each do |attr|
          @client.send(attr, connection_config[attr]) if connection_config[attr]
        end
      end

      def publish(topic, args, retain=false)
        @client.publish(topic, args, retain)
      end

      def connect
        @client.connect
      end

      def disconnect
        @client.disconnect
      end

      private

      def connection_config
        Muskrat.options[:config]&.[](Muskrat.env.env_str)&.[](:mqtt) || {
          host: 'localhost'
        }
      end
    end
  end
end
