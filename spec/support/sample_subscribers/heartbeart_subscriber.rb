require 'muskrat'

class HeartbeatSubscriber
  include Muskrat::Subscriber

  subscribe topic: "heartbeat/#", retain: true

  def perform
    # no-op
  end
end
