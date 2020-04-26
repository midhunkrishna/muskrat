require_relative '../spec_helper'

require 'muskrat'
require 'muskrat/subscription_handler'
require 'muskrat/mqtt/client'


describe Muskrat::SubscriptionHandler do
  def handler
    described_class.new(
      @channel,
      [{klass: 'NotificationSubscriber', topic: @channel.to_s}],
      @worker_count
    )
  end

  before(:each) do
    @channel = :notifications
    @worker_count = 1
    @handler = handler
    ENV['RAILS_ENV'] = 'production'
  end

  after(:each) do
    ENV['RAILS_ENV'] = nil
  end

  describe '#start' do
    it 'subscribes to mqtt channel' do
      allow(handler).to receive(:start_reader)
      allow(handler).to receive(:start_threadpool)

      expect_any_instance_of(Muskrat::Mqtt::Client).to receive(:connect)
      expect_any_instance_of(Muskrat::Mqtt::Client).to receive(:subscribe).with(@channel.to_s)

      handler.start
    end

    describe 'with reader thread' do
      before(:each)  do
        allow(@handler).to receive(:with_reader_thread) { |&blk| blk.call }
        allow(@handler).to receive(:subscribe_to_channel)
        allow(@handler).to receive(:start_threadpool)
      end

      it 'reconnects if mqtt client is not connected' do
        mqtt = double('connected?' => false)
        @handler.instance_variable_set(:@_mqtt_client, mqtt)

        expect(mqtt).to receive(:connect)

        @handler.start
      end

      it 'receives and acknowledges packet when mqtt client is connected' do
        mqtt = double('connected?' => true)
        @handler.instance_variable_set(:@_mqtt_client, mqtt)

        packet = OpenStruct.new(qos: 2)

        expect(mqtt).to receive(:receive_packet) do | &blk |
          blk.call(packet)
        end

        expect(mqtt).to receive(:puback_packet).with(packet)
        expect(@handler).to receive(:wrap).with(packet)

        @handler.start
      end

      it 'does not acknowledge received packet when qos is 0' do
        mqtt = double('connected?' => true)
        @handler.instance_variable_set(:@_mqtt_client, mqtt)

        packet = OpenStruct.new(qos: 0)

        expect(mqtt).to receive(:receive_packet) do | &blk |
          blk.call(packet)
        end

        expect(mqtt).not_to receive(:puback_packet).with(packet)
        expect(@handler).to receive(:wrap).with(packet)

        @handler.start
      end

      it 'wraps the received packet for as many subscribers there is' do
        packet =  OpenStruct.new(payload: Muskrat.dump_json({name: 'jameson'}))
        wrapped_data = @handler.send(:wrap, packet).last
        expect(wrapped_data[:klass]).to eq "NotificationSubscriber"
        expect(wrapped_data[:topic]).to eq "notifications"
        expect(wrapped_data[:message]).to eq({"name"=>"jameson"})
      end
    end

    describe "starts the threadpool executor" do
      before(:each) do
        allow(@handler).to receive(:subscribe_to_channel)
        allow(@handler).to receive(:start_reader)
      end

      it 'initializes muskrat threadpool with worker count and read queue' do
        client = Muskrat::Mqtt::Client.new
        @handler.instance_variable_set(:@_mqtt_client, client)
        expect(Muskrat::Threadpool).to receive(:new).with(@worker_count, client.read_queue).and_call_original
        expect_any_instance_of(Muskrat::Threadpool).to receive(:start)

        @handler.start
      end
    end
  end
end
