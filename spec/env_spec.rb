require_relative 'spec_helper'

require 'muskrat/env'
require 'rails'

describe 'Muskrat::Env' do
  it 'sets application environment in env instance' do
    env = Muskrat::Env.new({environment: 'staging'})
    expect(ENV['RAILS_ENV']).to eq 'staging'
    expect(ENV['RACK_ENV']).to eq 'staging'
  end

  context 'when requireable path is a directory' do
    after :each do
      ::Rails::VERSION.send(:remove_const, :MAJOR)
      ::Rails::VERSION.const_set(:MAJOR, 5)
    end

    it 'raises exception when rails version is lower than 5' do
      ::Rails::VERSION.send(:remove_const, :MAJOR)
      ::Rails::VERSION.const_set(:MAJOR, 4)

      env = Muskrat::Env.new({environment: 'staging', require: './spec/support/rails_dummy'})

      expect {
        env.load
      }.to raise_exception(RuntimeError, Muskrat::Env::RAILS_VERSION_NOT_SUPPORTED)
    end

    it 'loads rails env, when rails version is 5 or greater' do
      env = Muskrat::Env.new({environment: 'staging', require: './spec/support/rails_dummy'})
      expect(env).to receive(:require).with('rails')
      expect(env).to receive(:require).with(/config\/environment/)
      expect(env).to receive(:require).with('muskrat/rails_reloader')

      env.load
    end
  end

  context 'when requireable path is a file' do
    it 'requires the given file' do
      env = Muskrat::Env.new({environment: 'staging', require: 'ruby_main_app_file'})
      expect(env).to receive(:require).with('ruby_main_app_file')
      env.load
    end
  end

  context 'when requireable path is not given' do
    context 'when process directory is a rails app root' do
      it 'loads rails env from current directory' do
        expect(Dir).to receive(:pwd).and_return('./spec/support/rails_dummy')

        env = Muskrat::Env.new({environment: 'staging'})
        expect(env).to receive(:require).with('rails')
        expect(env).to receive(:require).with(/config\/environment/)
        expect(env).to receive(:require).with('muskrat/rails_reloader')

        env.load
      end
    end
  end
end
