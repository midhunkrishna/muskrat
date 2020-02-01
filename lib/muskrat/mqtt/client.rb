require 'mqtt'
require "muskrat/refinements/hash_refinements"

using HashRefinements

module Muskrat
  module Mqtt
    class Client
      MANUAL_ATTRS=['cert_file', 'cert', 'key_file', 'key', 'ca_file']

      def initialize
        # TODO
        # Client to not start read thread in future

        @client = ::MQTT::Client.new(connection_config.except(MANUAL_ATTRS))
        MANUAL_ATTRS.each do |attr|
          @client.send(attr, connection_config[attr]) if connection_config[attr]
        end
      end

      def publish(topic, data, retain=false)
        @client.publish(topic, data, retain)
      end

      def connect
        @client.connect
      end

      def disconnect
        @client.disconnect
      end

      private

      def connection_config
        env_str = Muskrat.env.env_str.to_sym
        Muskrat.options[:config]&.[](env_str)&.[](:mqtt) || {
          host: 'localhost'
        }
      end
    end
  end
end
