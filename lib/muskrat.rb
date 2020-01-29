require 'muskrat/version'
require 'muskrat/subscriber'
require 'muskrat/configurer'
require 'muskrat/env'
require 'muskrat/mqtt'

module Muskrat
  DEFAULTS = {
    subscriptions: [],
    concurrency: 10,
  }.freeze

  def self.options
    @options ||= DEFAULTS.dup
  end

  def self.env
    @env ||= begin
               env = Muskrat::Env.new(self.options)
               env.load
               env
             end
  end

  def self.configure &blk
    configurer = Muskrat::Configurer.new(options)
    blk.call(configurer)
  end
end
