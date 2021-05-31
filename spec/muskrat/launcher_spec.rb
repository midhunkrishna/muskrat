require_relative '../spec_helper'

require 'muskrat'
require 'muskrat/manager'
require 'muskrat/launcher'

describe Muskrat::Launcher do
  subject { Muskrat::Launcher.new(Muskrat.options) }
  signals = begin
              *everything, last = Muskrat::Launcher::SIG_LIST
              "#{everything.join(', ')} and #{last}"
            end

  describe '#run' do
    it 'sets up interrupts handlers' do
      # expect_any_instance_of(Muskrat::Manager).to receive(:run)
      read_end, write_end = ['read', 'write']
      expect(subject).to receive(:setup_interrupts).and_return([read_end, write_end])
      expect(subject).to receive(:handle_interrupts).with(read_end)

      subject.run
    end

    it "sets up trap signal for #{signals}" do
      Muskrat::Launcher::SIG_LIST.each do |signal|
        expect(subject).to receive(:trap).with(signal)
      end

      allow(subject).to receive(:handle_interrupts)
      subject.run
    end

    it 'starts Muskrat::Manager, and stops if an interrupt is received' do
      read_end, write_end = IO.pipe
      expect(subject).to receive(:setup_interrupts).and_return([read_end, write_end])

      write_end.puts("INT")

      expect_any_instance_of(Muskrat::Manager).to receive(:run)
      expect_any_instance_of(Muskrat::Manager).to receive(:stop)
      subject.run
    end
  end
end
