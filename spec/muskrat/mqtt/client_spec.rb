require 'muskrat'
require 'muskrat/mqtt/client'


describe 'Muskrat::Mqtt::Client' do
  before(:all) do
    @env_str = ENV['RAILS_ENV']
    ENV['RAILS_ENV'] = 'production'
  end

  after(:all) do
     ENV['RAILS_ENV'] = @env_str
  end

  describe '#connect' do
    it 'connects to mqtt server' do
      @mqtt_client = double('client')
      expect(MQTT::Client).to receive(:new).and_return(@mqtt_client)

      expect(@mqtt_client).to receive(:connect)
      client = Muskrat::Mqtt::Client.new
      client.connect
    end
  end

  describe '#publish' do
    it 'publishes incoming data to mqtt client' do
      @mqtt_client = double('client')
      expect(MQTT::Client).to receive(:new).and_return(@mqtt_client)

      expect(@mqtt_client).to receive(:publish).with('topic', {}, true)
      client = Muskrat::Mqtt::Client.new
      client.publish(topic='topic', data={}, retain=true)
    end
  end

  describe '#disconnect' do
    it 'disconnects from mqtt server' do
      @mqtt_client = double('client')
      expect(MQTT::Client).to receive(:new).and_return(@mqtt_client)

      expect(@mqtt_client).to receive(:disconnect)
      client = Muskrat::Mqtt::Client.new
      client.disconnect
    end
  end

  describe '.new' do
    it 'returns configured MQTT::Client' do
      Muskrat.configure do |conf|
        conf.config_file = File.join(File.expand_path('../../', __FILE__), 'support/config.yml')
      end

      client = Muskrat::Mqtt::Client.new
      expect(client.instance_variable_get(:@client)).to be_a(MQTT::Client)
    end
  end
end
