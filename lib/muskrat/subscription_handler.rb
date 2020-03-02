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
      @_work_queue = Queue.new

      subscribe_to_channel
      start_reader
      start_preprocessor
      start_threadpool
    end

    private

    def subscribe_to_channel
      @_mqtt_client = Muskrat::Mqtt::Client.new(::MQTT::Client)
      @_mqtt_client.connect
      @_mqtt_client.subscribe(@channel)
    end

    def start_reader
      @_reader = Thread.new do
        begin
          loop do
            if @_mqtt_client.connected?
              @_mqtt_client.receive_packet
            else
              raise Muskrat::Mqtt::ConnectionClosed
            end
          end
        rescue
          connect_mqtt unless @_mqtt_client.connected?
          ##
          # Report exception / logger
          retry
        end
      end
    end

    def wrap(message)
      @subscribers.map do |subscriber|
        subscriber.merge!(message: message)
      end
    end

    def start_preprocessor
      @_preprocessor = Thread.new do
        loop do
          message = @_mqtt_client.read_queue.pop
          @_work_queue.push(*wrap(message))
        end
      end
    end

    def start_threadpool
      @_threadpool = Muskrat::Threadpool.new(
        @_work_queue,
        @subscribers,
        @worker_count,
        -> (packet) { @_mqtt_client.puback_packet(packet) if packet.qos > 0 }
      )
    end
  end
end
