require 'muskrat/version'
require 'muskrat/configuration'
require 'muskrat/env'
require 'muskrat/mqtt'

require 'muskrat/subscriber'
require 'muskrat/publisher'
require 'json'


module Muskrat
  DEFAULTS = {
    subscriptions: [],
    concurrency: 10,
  }.freeze

  def self.options
    @options ||= DEFAULTS.dup
  end

  def self.env
    ##
    # TODO:
    # Log information that Rails env is booted.

    @env ||= begin
               env = Muskrat::Env.new(self.options)
               env.load_application
               env
             end
  end

  def self.configure &blk
    configurer = Muskrat::Configuration::Loader.new(options)
    blk.call(configurer)
  end

  def self.load_json(string)
    JSON.parse(string)
  end

  def self.dump_json(object)
    JSON.generate(object)
  end
end
