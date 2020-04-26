require "muskrat"
require "muskrat/configuration"
require "muskrat/mqtt"

module Muskrat
  module Publisher
    SUBSCRIBER_NOT_FOUND='No subscribers specified/loaded for topic: %{topic}.'

    module ClassMethods
      def publish(topic, args, retain=false)
        Muskrat::Mqtt.with_client do |client|
          unless Muskrat.options[:subscriber_config].has_key?(topic.to_sym)
            Muskrat::Logger.log(SUBSCRIBER_NOT_FOUND)
          end

          ###
          # TODO:
          # Generate and assign a UID to each of these messages
          # once we have dump and load in place
          client.publish(topic, Muskrat.dump_json(args), retain)
        end
      end
    end

    def self.included(base)
      base.extend(ClassMethods)
    end
  end
end
