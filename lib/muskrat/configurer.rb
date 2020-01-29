require "optparse"
require "yaml"

require "muskrat/logger"

module Muskrat
  class Configurer

    CONFIG_FILE_NOT_FOUND = "Configuration file not found. Muskrat will fallback to default configurations".freeze

    def self.parse_from_cli(args)
      configurer = new({})
      configurer.parse_and_load_config(args)
    end

    def self.reconcile_subscription(opts, subscription)
      topics = Array(subscription[:topic]).map(&:to_sym)
      config = opts[:subscriber_config].dup || {}
      topics.each do |topic|
        config[topic] ||= []

        config[topic].push({
          klass: subscription[:subscriber],
          topic: topic.to_s,
        })
      end
      {subscriber_config: config}
    end

    def initialize(options)
      @options = options
    end

    def config_file=(file_path)
      @options[:config_file]=file_path
      load_config
    end

    def parse_and_load_config(args)
      parse_options(args)
      load_config
      @options
    end

    private

    def parse_options(args)
      parser = OptionParser.new { |o|
        o.on "-C", "--config PATH[FILE]", "path to yaml config file" do |arg|
          @options[:config_file] = arg
        end

        o.on "-R", "--require PATH[DIR|FILE]", "path to Rails root or main file" do |arg|
          @options[:require] = arg
        end

        o.on "-e", "--environment STR", "your application environment" do |arg|
          @options[:environment] = arg
        end
      }

      parser.banner = "Muskrat /options/"
      parser.on_tail "-h", "--help", "Show Help" do
        puts parser
        exit 1
      end

      parser.parse!(args)
    end

    def load_config
      file_path = @options[:config_file]
      if file_path && File.exist?(file_path)
        @options[:config] = YAML.safe_load(File.read(file_path), [Symbol])
      else
        Muskrat::Logger.log(CONFIG_FILE_NOT_FOUND)
      end
    end
  end
end
