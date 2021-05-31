require_relative '../spec_helper'

require 'muskrat'
require 'muskrat/job_runner'
require 'muskrat/threadpool'

describe Muskrat::Threadpool do
  it 'creates are many threads as the specified pool size' do
    threadpool = Muskrat::Threadpool.new(2, Queue.new)
    expect(threadpool).to receive(:setup_worker).twice
    threadpool.start
  end

  context 'worker' do
    it 'pulls a job from the job queue and executes it' do
      job_queue, job = ['job'], 'job'
      job_queue.push(job)

      threadpool = Muskrat::Threadpool.new(1, job_queue)

      expect(threadpool).to receive(:with_worker_loop) { | &blk | blk.call }
      expect(threadpool.instance_variable_get(:@mutex)).to receive(:synchronize) do | &blk |
        blk.call
      end
      
      expect(job_queue).to receive(:pop).and_call_original
      expect(Muskrat::JobRunner).to receive(:new).with(job)

      threadpool.start
      threadpool.shutdown
    end
  end

  context 'monitor' do
    it 'adds a new worker thread when a worker perishes' do
      threadpool = Muskrat::Threadpool.new(0, [])
      expect(threadpool).to receive(:setup_worker)

      expect(threadpool).to receive(:with_monitor_loop) { | &blk | blk.call }
      threadpool.instance_variable_set(:@monitor_queue, ['failed_thread'])
      threadpool.start
    end
  end

  describe '#shutdown' do
    subject { Muskrat::Threadpool.new(2, Queue.new) }

    it 'shutsdown the started threadpool' do
      subject.start
      subject.shutdown
      
      expect(subject).not_to be_running
    end
  end
end
