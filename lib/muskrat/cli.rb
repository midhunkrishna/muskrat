require "muskrat"
require "muskrat/configurer"
require "muskrat/env"

module Muskrat
  class CLI
    def parse(args = ARGV)
      populate_options(args)
      load_requireable_env
    end

    private

    def launch
    end

    def options
      Muskrat.options
    end

    def load_requireable_env
      Muskrat.env
    end

    def populate_options(args)
      options.merge!(Muskrat::Configurer.parse_from_cli(args))
    end
  end
end
