require 'muskrat'

class NotificationSubscriber
  include Muskrat::Subscriber

  subscribe topic: "notifications", retain: true

  def perform
    # no-op
  end
end
