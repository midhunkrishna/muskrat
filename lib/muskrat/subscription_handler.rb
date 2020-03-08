require 'muskrat'
require 'muskrat/mqtt/client'
require 'muskrat/refinements/mqtt_client_refinements'
require 'muskrat/threadpool'

using MqttClientRefinements

# @_mqtt_client
# @_reader
# @_pool

module Muskrat
  class SubscriptionHandler
    def initialize(channel, subscribers, worker_count)
      @channel, @subscribers, @worker_count = channel, subscribers, worker_count
    end

    def start
      subscribe_to_channel
      start_reader
      start_threadpool
    end


    private

    def subscribe_to_channel
      @_mqtt_client = Muskrat::Mqtt::Client.new(::MQTT::Client)
      @_mqtt_client.connect
      @_mqtt_client.subscribe(@channel.to_s)
    end

    def wrap(packet)
      @subscribers.map do |subscriber|
        subscriber.merge!(message: packet)
      end
    end

    def start_reader
      @_reader = Thread.new do
        begin
          loop do
            if @_mqtt_client.connected?
              @_mqtt_client.receive_packet do | packet |
                wrap(packet)
                @_mqtt_client.puback_packet(packet) if packet.qos > 0
              end
            else
              raise Muskrat::Mqtt::ConnectionClosed
            end
          end
        rescue
          @_mqtt_client.connect unless @_mqtt_client.connected?
          ##
          # TODO:
          # Report exception / logger
          retry
        end
      end
    end

    def start_threadpool
      ##
      # TODO:
      # Load into read queue, persisted data on last shutdown
      # Clear existing data in storage

      @_threadpool = Muskrat::Threadpool.new(
        @worker_count,
        @_mqtt_client.read_queue
      )
    end
  end
end
