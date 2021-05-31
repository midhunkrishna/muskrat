require 'muskrat'
require 'muskrat/manager'

module Muskrat
  class Launcher
    SIG_LIST = %w[INT TERM TTIN TSTP CONT]
    def initialize(options)
      @manager = Muskrat::Manager.new(options)
    end

    def run
      ##
      # TODO:
      # From here on, muskrat is multi threaded, log the information

      read_end, = setup_interrupts
      handle_interrupts(read_end)
    end


    private

    def setup_interrupts
      read_end, write_end = IO.pipe
      SIG_LIST.each do |signal|
        trap signal do
          write_end.puts(signal)
        end
      rescue ArgumentError
        puts "Received signal #{signal} not supported"
      end

      [read_end, write_end]
    end

    def handle_interrupts(read_end)
      @manager.run

      while (io = IO.select([read_end]))
        handler = "handle_#{io.first[0].gets.strip}"
        if respond_to?(handler, true)
          send(handler)
        else
          puts 'No handler registered. Ignoring..'
        end
      end
    rescue Interrupt
      @manager.stop
      puts "Bye!"
    end

    def handle_INT
      puts 'Interrupt received, shutting down'
      raise Interrupt
    end

    def handle_TERM
      puts 'Interrupt received, shutting down'
      raise Interrupt
    end

    def handle_TTIN
      ##
      # TODO:
      # Print @manager.status
    end

    def handle_CONT
      puts "Interrupt received, resuming normal execution"
      @manager.resume
    end

    def handle_TSTP
      puts "Interrupt received, sleeping until SIGCONT"
      @manager.pause
    end
  end
end
