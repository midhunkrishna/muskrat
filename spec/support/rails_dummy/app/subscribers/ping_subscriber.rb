require 'muskrat'
require 'pry-byebug'

class PingSubscriber
  include Muskrat::Subscriber
  include Muskrat::Publisher

  ###
  # TODO:
  # Pass retain into the mqtt library
  subscribe topic: "ping-pong", retain: false

  def perform(data)
    count = data['count'] || 0;

    puts data.inspect
    puts "sending ping... @ #{count}"

    self.class.publish('ping-pong', {count: count+1, message: 'ping'})
  end
end
