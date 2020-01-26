require "muskrat"
require "mqtt"

module Muskrat
  class Client
    def initialize
      @client = MQTT::Client.connect(connection_options)
    end

    def publish_async
    end

    def publish
    end

    private

    def connection_options
      options = Muskrat.options[:mqtt] || {}.reject do |_, value|
        value.nil? || value.empty?
      end

      {
        host: "localhost",
        post: 1833,
      }.merge(options)
    end
  end
end
