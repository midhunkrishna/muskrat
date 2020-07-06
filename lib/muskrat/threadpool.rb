require 'muskrat'
require 'muskrat/job_runner'

require 'pry-byebug'

module Muskrat
  class Threadpool
    def initialize(pool_size, job_queue)
      @pool, @pool_size = [], pool_size
      @job_queue, @monitor_queue = job_queue, Queue.new

      @mutex, @monitor_mutex = Mutex.new, Mutex.new
      @stop = false
    end

    def start
      @pool_size.times do
        setup_worker
      end
      start_monitor
    end

    def shutdown
      ##
      # TODO:
      # Persist current executing thread data
      [@monitor, *@pool].map{ |thread| thread.kill.join }
    end

    def running?
      @monitor.alive? || @pool.any? { |thread| thread.alive? }
    end

    private

    def with_monitor_loop &block
      unless @monitor
        @monitor = Thread.new do
          loop do
            block.call
          end
        end
      end
    end

    def start_monitor
      with_monitor_loop do
        failed_thread = @pool.detect { |thread| thread.object_id == @monitor_queue.pop }
        @pool.delete(failed_thread)
        setup_worker

        ##
        # TODO:
        # Publish pool health.
      end
    end

    def with_worker_loop &block
      @pool << Thread.new do
        loop do
          block.call
        end
      end
    end

    def setup_worker
      with_worker_loop do
        job = @mutex.synchronize {
          @job_queue.pop
        }

        begin
          Muskrat::JobRunner.new(job).execute
        rescue
          ##
          # TODO
          # report exception / logger
          @monitor_mutex.synchronize {
            @monitor_queue << Thread.current.object_id
          }
        end
      end
    end
  end
end
