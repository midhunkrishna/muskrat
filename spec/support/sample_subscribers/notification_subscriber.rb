require 'muskrat'

class NotificationSubscriber
  include Muskrat::Subscriber

  subscribe topic: "notifications"

  def perform
    # no-op
  end
end
