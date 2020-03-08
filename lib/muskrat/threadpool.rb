require 'muskrat'

module Muskrat
  class Threadpool
    def initialize(pool_size, job_queue)
      @pool, @pool_size = [], pool_size
      @mutex, @monitor_mutex = Mutex.new, Mutex.new
      @job_queue, @monitor_queue = job_queue, Queue.new
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
      # Kill thread
    end

    private

    def start_monitor
      @monitor = Thread.new do
        loop do
          failed_thread = @pool.detect { |thread| thread.object_id == @monitor_queue.pop }
          @pool.delete(failed_thread)
          setup_worker

          ##
          # TODO:
          # Publish pool health.
        end
      end
    end

    def setup_worker
      @pool << Thread.new do
        loop do
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
end
