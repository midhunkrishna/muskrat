require 'muskrat'
require 'muskrat/configuration/guard'

module Muskrat
  module Configuration
    class Loader
      CONFIG_FILE_NOT_FOUND = "Configuration file not found. Muskrat will fallback to default configurations".freeze

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

      def env=(env_str)
        @options[:environment] = env_str
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
          verify!
        else
          Muskrat::Logger.log(CONFIG_FILE_NOT_FOUND)
        end
      end

      def verify!
        Guard.new(@options[:config]).verify!
      end
    end
  end
end
