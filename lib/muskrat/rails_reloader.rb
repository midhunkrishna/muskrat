module Muskrat
  class RailsReloader
    # https://guides.rubyonrails.org/threading_and_code_execution.html#reloader

    # Rails seperates application code and framework code using Rails Executor.
    # Each thread is advised to be wrapped inside Rails Executor before it runs application code.
    # For long running framework processes, in this case Muskrat, it is advised to use Reloader.

    def initialize(app)
      @app = app
    end

    def call
      @app.reloader.wrap do
        yield
      end
    end
  end
end
