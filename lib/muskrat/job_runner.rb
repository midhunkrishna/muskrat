require 'muskrat'

module Muskrat
  class JobRunner
    def initialize(job)
      @job = job
    end

    def execute
      klass_name = @job[:klass].to_s
      klass = klass_name.respond_to?(:constantize) ? klass_name.constantize : const_get(klass_name)
      klass.new.perform(@job[:message])
    end
  end
end
