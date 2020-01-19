require 'muskrat'

class NoTopicSubscriber
  include Muskrat::Subscriber

  ##
  # A subscribe call without a topic will result in a
  # "Topic Not Specified" exception.

  subscribe

  def perform
    # no-op
  end
end
