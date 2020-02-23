require 'muskrat/version'
require 'muskrat/configuration'
require 'muskrat/env'
require 'muskrat/mqtt'

require 'muskrat/subscriber'
require 'muskrat/publisher'


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
               env.load
               env
             end
  end

  def self.configure &blk
    configurer = Muskrat::Configuration::Loader.new(options)
    blk.call(configurer)
  end
end
