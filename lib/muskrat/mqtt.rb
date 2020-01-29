require_relative './mqtt/client'

module Muskrat
  module Mqtt
    def self.with_client &blk
      begin
        client = Muskrat::Mqtt::Client.new
        client.connect
        block.call(client)

      ensure
        client.disconnect
      end
    end
  end
end
