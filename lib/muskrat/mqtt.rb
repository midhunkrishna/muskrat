require_relative './mqtt/client'
require_relative './mqtt/connection_closed'

module Muskrat
  module Mqtt
    def self.with_client &blk
      begin
        client = Muskrat::Mqtt::Client.new
        client.connect
        blk.call(client)
      ensure
        client.disconnect
      end
    end
  end
end
