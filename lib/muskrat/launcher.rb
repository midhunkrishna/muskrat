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
      manager.run
    end
  end
end
