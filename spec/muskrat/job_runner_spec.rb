require_relative '../spec_helper'

require 'muskrat'
require 'muskrat/job_runner'

describe 'Muskrat::JobRunner' do
  class Muskrat::TestSubscriber
    def perform(data)
    end
  end

  describe '#execute' do
    it 'constantizes a subscriber class and calls perform instance method on it' do
      job = {message: {}, klass: 'Muskrat::TestSubscriber'}

      expect_any_instance_of(Muskrat::TestSubscriber).to receive(:perform).with({})
      Muskrat::JobRunner.new(job).execute
    end
  end
end
