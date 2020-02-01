require "muskrat/rails_reloader"

module Muskrat
  class Env
    DEVELOPMENT = "development".freeze
    RAILS_VERSION_NOT_SUPPORTED = "Muskrat only supports Rails version 5 or above.".freeze

    attr_reader :options

    def initialize(options)
      @options = options
      set_execution_env(options[:environment])
      @path = options[:require] || gather_from_fs
    end

    def load
      load_environment
    end

    def env_str
      @options[:environment] || ENV["RAILS_ENV"]|| ENV["RACK_ENV"]
    end

    private

    def set_execution_env(env_str)
      ENV["RAILS_ENV"] = ENV["RACK_ENV"] = env_str if env_str
    end

    def load_environment
      return unless @path

      if File.directory?(@path)
        require "rails"
        if ::Rails::VERSION::MAJOR < 5
          raise RAILS_VERSION_NOT_SUPPORTED
        else
          require ::File.expand_path("config/environment", @path)
          require "muskrat/rails_reloader"

          options[:reloader] = Muskrat::RailsReloader.new(::Rails.application)
        end

      else
        require @path.to_s
      end
    end

    def gather_from_fs
      pwd = Dir.pwd
      return pwd if File.exist?("#{pwd}/config/application.rb")
    end
  end
end
