require 'muskrat'

class EventSubscriber
  include Muskrat::Subscriber

  subscribe topic: "events/#"

  def perform
    # no-op
  end
end
