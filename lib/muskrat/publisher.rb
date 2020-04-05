require "muskrat"
require "muskrat/configuration"
require "muskrat/mqtt"

module Muskrat
  class Publisher
    SUBSCRIBER_NOT_FOUND='No subscribers specified/loaded for topic: %{topic}.'

    def self.publish(topic, args, retain=false)
      Muskrat::Mqtt.with_client do |client|
        Muskrat::Logger.log(SUBSCRIBER_NOT_FOUND) unless subscribed?(topic)
        client.publish(topic, args, retain)
      end
    end

    private_class_method def self.subscribed?(topic)
                           Muskrat.options[:subscriber_config].has_key?(topic.to_sym)
                         end
  end
end
