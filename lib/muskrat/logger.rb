module Muskrat
  class Logger
    class << self
      $stdout.sync = true

      def log(str)
        puts str
      end
    end
  end
end
