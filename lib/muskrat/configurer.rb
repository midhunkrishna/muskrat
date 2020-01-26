require "optparse"
require "yaml"

require "muskrat/logger"

module Muskrat
  class Configurer
    attr_reader :options

    CONFIG_FILE_NOT_FOUND = "Configuration file not found. Muskrat will fallback to default configurations".freeze

    def self.parse_from_cli(args)
      @options = parse_options(args)
      load_config(@options)
      @options
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

    private

    private_class_method def self.parse_options(args, opts = {})
      parser = OptionParser.new { |o|
        o.on "-C", "--config PATH[FILE]", "path to yaml config file" do |arg|
          opts[:config_file] = arg
        end

        o.on "-R", "--require PATH[DIR|FILE]", "path to Rails root or main file" do |arg|
          opts[:require] = arg
        end

        o.on "-e", "--environment STR", "your application environment" do |arg|
          opts[:environment] = arg
        end
      }

      parser.banner = "Muskrat /options/"
      parser.on_tail "-h", "--help", "Show Help" do
        puts parser
        exit 1
      end

      parser.parse!(args)
      opts
    end

    private_class_method def self.load_config(opts)
      file_path = opts[:config_file]
      if file_path && File.exist?(file_path)
        opts[:config] = YAML.safe_load(File.read(file_path))
      else
        Muskrat::Logger.log(CONFIG_FILE_NOT_FOUND)
      end
    end
  end
end
