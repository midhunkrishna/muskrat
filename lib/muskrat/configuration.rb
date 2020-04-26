require "optparse"
require "yaml"

require "muskrat/logger"
require "muskrat/configuration/loader"

module Muskrat
  module Configuration
    class LoadError < StandardError; end

    def self.parse_from_cli(args)
      configurer = Loader.new({})
      configurer.parse_and_load_config(args)
    end

    def self.reconcile_subscription(opts, subscription)
      topics = Array(subscription[:topic]).map(&:to_sym)
      config = opts[:subscriber_config]&.dup || {}
      topics.each do |topic|
        config[topic] ||= []

        config[topic].push({
          klass: subscription[:subscriber],
          topic: topic.to_s,
        })
      end
      {subscriber_config: config}
    end
  end
end
