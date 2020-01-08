require 'optparse'

require 'muskrat'

module Muskrat
  class CLI
    def parse(args=ARGV)
      populate_options(args)
    end

    private

    def populate_options(args)
      options = parse_options(args)
      puts options.inspect
    end

    def parse_options(args, opts={})
      parser = OptionParser.new do |o|
        o.on "-C", "--config PATH", "path to yaml config file" do |arg|
          opts[:config_file] = arg
        end
      end

      parser.banner = "Muskrat /options/"
      parser.on_tail "-h", "--help", "Show Help" do
        puts parser
        exit 1
      end

      parser.parse!(args)
      opts
    end
  end
end
