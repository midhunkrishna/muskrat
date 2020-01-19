require 'muskrat'

class MultiSubscriber
  include Muskrat::Subscriber

  subscribe topic: %i(events/# notifications alarms)

  def perform
    # no-op
  end
end
