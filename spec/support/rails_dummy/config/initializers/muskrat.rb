require 'muskrat'

Muskrat.configure do |config|
  config.config_file = File.join(Rails.root, 'muskrat.yml')
  config.env = ENV['RAILS_ENV']
end
