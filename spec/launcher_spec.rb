require_relative 'spec_helper'

require 'muskrat'
require 'muskrat/manager'
require 'muskrat/launcher'

describe Muskrat::Launcher do
  it '#run' do
    expect_any_instance_of(Muskrat::Manager).to receive(:run)
    Muskrat::Launcher.new(Muskrat.options).run
  end
end
