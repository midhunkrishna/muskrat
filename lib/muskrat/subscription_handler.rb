require 'muskrat'

require 'muskrat/mqtt'
require 'muskrat/threadpool'
require_relative '../refinements/refined_mqtt_client'

using RefinedMqttClient

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

    def read_from_mqtt
      if @_mqtt_client.connected?
        @_mqtt_client.receive_packet do | packet |
          @_mqtt_client.puback_packet(packet) if packet.qos > 0
          wrap(packet)
        end
      else
        raise Muskrat::Mqtt::ConnectionClosed
      end
    end

    def with_reader_thread &block
      @_reader = Thread.new do
        loop do
          block.call
        end
      end
    end

    def start_reader
      with_reader_thread do
        begin
          read_from_mqtt
        rescue
          @_mqtt_client.connect unless @_mqtt_client.connected?
          ##
          # TODO:
          # Report exception / logger
          # Timed retry
        end
      end
    end

    def start_threadpool
      ##
      # TODO:
      # Persisted data on last shutdown should be loaded into read queue
      # Clear existing data in storage

      @_threadpool = Muskrat::Threadpool.new(
        @worker_count,
        @_mqtt_client.read_queue
      )

      @_threadpool.start
    end
  end
end
