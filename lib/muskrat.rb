require "muskrat/version"

module Muskrat
  DEFAULTS = {
    subscriptions: [],
    concurrency: 10,
  }

  def self.options
    @options ||= DEFAULTS.dup
  end
end
