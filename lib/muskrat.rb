require 'muskrat/version'
require 'muskrat/subscriber'

module Muskrat
  DEFAULTS = {
    subscriptions: [],
    concurrency: 10,
  }.freeze

  def self.options
    @options ||= DEFAULTS.dup
  end
end
