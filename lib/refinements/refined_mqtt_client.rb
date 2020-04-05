require 'mqtt'

module RefinedMqttClient
  refine ::MQTT::Client do
    def handle_packet(packet, block)
      if packet.class == MQTT::Packet::Publish
        # Add to queue
        @read_queue.push(*block.call(packet))
      elsif packet.class == MQTT::Packet::Pingresp
        @last_ping_response = Time.now
      elsif packet.class == MQTT::Packet::Puback
        @pubacks_semaphore.synchronize do
          @pubacks[packet.id] = packet
        end
      end
      # Ignore all other packets
      # FIXME: implement responses for QoS  2
    end

    def receive_packet &block
      begin
        # Poll socket - is there data waiting?
        result = IO.select([@socket], [], [], SELECT_TIMEOUT)
        unless result.nil?
          # Yes - read in the packet
          packet = MQTT::Packet.read(@socket)
          handle_packet(packet, block)
        end
        keep_alive!
        # Pass exceptions up to parent thread
      rescue Exception => e
        unless @socket.nil?
          @socket.close
          @socket = nil
        end

        raise e
      end
    end

    def connect(clientid=nil)
      unless clientid.nil?
        @client_id = clientid
      end

      if @client_id.nil? or @client_id.empty?
        if @clean_session
          if @version == '3.1.0'
            # Empty client id is not allowed for version 3.1.0
            @client_id = MQTT::Client.generate_client_id
          end
        else
          raise 'Must provide a client_id if clean_session is set to false'
        end
      end

      if @host.nil?
        raise 'No MQTT server host set when attempting to connect'
      end

      if not connected?
        # Create network socket
        tcp_socket = TCPSocket.new(@host, @port)

        if @ssl
          # Set the protocol version
          if @ssl.is_a?(Symbol)
            ssl_context.ssl_version = @ssl
          end

          @socket = OpenSSL::SSL::SSLSocket.new(tcp_socket, ssl_context)
          @socket.sync_close = true

          # Set hostname on secure socket for Server Name Indication (SNI)
          if @socket.respond_to?(:hostname=)
            @socket.hostname = @host
          end

          @socket.connect
        else
          @socket = tcp_socket
        end

        # Construct a connect packet
        packet = MQTT::Packet::Connect.new(
          :version => @version,
          :clean_session => @clean_session,
          :keep_alive => @keep_alive,
          :client_id => @client_id,
          :username => @username,
          :password => @password,
          :will_topic => @will_topic,
          :will_payload => @will_payload,
          :will_qos => @will_qos,
          :will_retain => @will_retain
        )

        # Send packet
        send_packet(packet)

        # Receive response
        receive_connack

        # disabling packet reading thread

        # @read_thread = Thread.new(Thread.current) do |parent|
        #   Thread.current[:parent] = parent
        #   while connected? do
        #     receive_packet
        #   end
        # end
      end
    end
  end
end
