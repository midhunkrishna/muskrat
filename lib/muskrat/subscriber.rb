require 'muskrat'

module Muskrat
  module Subscriber
    module ClassMethods
      def publish(*args)
      end
    end

    def self.included(base)
      base.extend(ClassMethods)
    end
  end
end
