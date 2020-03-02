require 'forwardable'

require 'mqtt'
require "muskrat/refinements/hash_refinements"

using HashRefinements

module Muskrat
  module Mqtt
    class Client
      MANUAL_ATTRS=['cert_file', 'cert', 'key_file', 'key', 'ca_file']

      extend Forwardable

      attr_reader :read_queue

      def_delegators :@client, :connect, :connected?, :disconnect, :subscribe, :receive_packet

      def initialize
        @client = ::MQTT::Client.new(connection_config.except(MANUAL_ATTRS))
        MANUAL_ATTRS.each do |attr|
          @client.send(attr, connection_config[attr]) if connection_config[attr]
        end

        @read_queue = @client.instance_variable_get(:@read_queue)
      end

      def publish(topic, data, retain=false)
        @client.publish(topic, data, retain)
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
