require 'muskrat'
require 'muskrat/configurer'
require 'muskrat/env'

module Muskrat
  class CLI
    def parse(args=ARGV)
      populate_options(args)
      @env = load_requireable_env
    end


    private

    def launch
    end

    def options
      Muskrat.options
    end

    def populate_options(args)
      options.merge!(Muskrat::Configurer.new(args).options)
    end

    def load_requireable_env
      env = Muskrat::Env.new(options)
      env.load
      env
    end
  end
end
