require_relative 'spec_helper'
require 'muskrat/cli'
require 'muskrat/env'

describe 'Muskrat::CLI' do
  let(:rails_root) { './spec/support/rails_dummy' }
  subject { Muskrat::CLI.new }

  describe 'parse' do
    before :each do
      allow_any_instance_of(Muskrat::Env).to receive(:load)
    end

    it 'configures yml file to load, -C [PATH]' do
      subject.parse(['-C', './spec/support/config.yml'])
      expect(Muskrat.options).to include({config_file: './spec/support/config.yml'})
    end

    it 'configures file/dir that needs to be required, -R [PATH|FILE]' do
      expect(Muskrat::Logger)
        .to receive(:log).with(Muskrat::Configuration::Loader::CONFIG_FILE_NOT_FOUND)
      subject.parse(['-R', 'rails_root'])
      expect(Muskrat.options).to include({require: 'rails_root'})
    end

    it 'configures environment string, -e [STR]' do
      expect(Muskrat::Logger)
        .to receive(:log).with(Muskrat::Configuration::Loader::CONFIG_FILE_NOT_FOUND)
      subject.parse(['-e', 'staging'])
      expect(Muskrat.options).to include({environment: 'staging'})
    end

    describe 'load_config' do
      it 'loads configuration in file to Muskrat.options' do
        subject.parse(['-C', './spec/support/config.yml'])
        expect(Muskrat.options[:config]).not_to be_empty
      end

      context 'when provided file doesnt exist' do
        it 'logs file not found to stdout' do
          expect(Muskrat::Logger).to receive(:log)
          subject.parse(['-C', 'not_a_findable_file'])
        end
      end
    end
  end
end
