require 'muskrat'

class SecondaryEventSubscriber
  include Muskrat::Subscriber

  subscribe topic: "events/#"

  def perform
    # no-op
  end
end
