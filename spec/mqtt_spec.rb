require 'muskrat/mqtt'

describe 'Muskrat::Mqtt' do
  describe '.with_client' do
    before(:each) do
      @client = double('mqtt_client')
    end

    it 'yields given block with client' do
      allow(Muskrat::Mqtt::Client).to receive(:new).and_return(@client)
      expect(@client).to receive(:connect)
      expect(@client).to receive(:disconnect)

      Muskrat::Mqtt.with_client do |client|
        expect(client).to eq @client
      end
    end

    it 'disconnects the client after yielding the block' do
      allow(Muskrat::Mqtt::Client).to receive(:new).and_return(@client)
      expect(@client).to receive(:connect)
      expect(@client).to receive(:disconnect)

      Muskrat::Mqtt.with_client do |client|
        expect(client).to eq @client
      end
    end
  end
end
