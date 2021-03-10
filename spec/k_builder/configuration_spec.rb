# frozen_string_literal: true

require 'tmpdir'

RSpec.describe KBuilder::Configuration do
  let(:builder_module) { KBuilder }
  let(:temp_folder) { Dir.mktmpdir('my-kbuilder-project') }
  let(:cfg) { ->(config) {} }

  before :each do
    builder_module.configure(&cfg)
  end
  after :each do
    builder_module.reset
  end

  describe '.target_folder_base' do
    subject { builder_module.configuration.target_folder_base }

    context 'when not configured' do
      it { is_expected.to eq(Dir.getwd) }
    end

    context 'when configured' do
      let(:cfg) do
        lambda { |config|
          config.target_folder_base = temp_folder
        }
      end

      it { is_expected.to eq(temp_folder) }
    end
  end

  describe '.global_template_folder' do
    subject { builder_module.configuration.global_template_folder }

    context 'when not configured' do
      it { is_expected.to eq(File.join(Dir.getwd, '.templates')) }
    end

    context 'when configured' do
      let(:cfg) do
        lambda { |config|
          config.global_template_folder = '/some-folder'
        }
      end

      it { is_expected.to eq('/some-folder') }
    end
  end
end
