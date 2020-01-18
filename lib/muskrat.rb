require "muskrat/version"

module Muskrat
  DEFAULTS = {
    subscriptions: [],
    concurrency: 10,
  }.freeze

  def self.options
    @options ||= DEFAULTS.dup
  end
end
