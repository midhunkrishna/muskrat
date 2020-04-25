require 'muskrat'

class PingSubscriber
  include Muskrat::Subscriber
  include Muskrat::Publisher

  subscribe topic: "ping-pong", retain: false

  def perform(data)
    count = data['count'] || 0;

    Rails.logger.debug data.inspect
    Rails.logger.debug "sending ping... @ #{count}"

    client = Muskrat::Mqtt::Client.new
    client.publish('ping-pong', {count: count+1, message: 'ping'})
  end
end
