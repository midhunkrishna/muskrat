require 'muskrat'
require 'muskrat/manager'

module Muskrat
  class Launcher
    def initialize(options)
      @manager = Muskrat::Manager.new(options)
    end

    def run
      ##
      # TODO:
      # From here on, muskrat is multi threaded, log the information
      @manager.run

      ###
      # TODO:
      # Wait for interrupts and react accordingly
      # for now, simple bailout with loop

      unless ENV['GEM_ENV'] == 'test'
        loop do
          sleep 2
        end
      end
    end
  end
end
