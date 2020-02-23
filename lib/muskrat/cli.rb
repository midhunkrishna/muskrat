require "muskrat"
require "muskrat/configuration"
require "muskrat/launcher"
require "muskrat/env"

module Muskrat
  class CLI
    def parse(args = ARGV)
      populate_options(args)
      load_requireable_env
    end

    def launch
      @launcher = Muskrat::Launcher.new(options)
      @launcher.run
    end


    private

    def stop
      # @launcher.slow_down
      # @launcher.terminate
    end

    def options
      Muskrat.options
    end

    def load_requireable_env
      Muskrat.env
    end

    def populate_options(args)
      options.merge!(Muskrat::Configuration.parse_from_cli(args))
    end
  end
end
