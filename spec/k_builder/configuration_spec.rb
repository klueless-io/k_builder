# frozen_string_literal: true

RSpec.describe KBuilder::Configuration do
  let(:builder_module) { KBuilder }
  let(:custom_target_folder_base) { 'my-kbuilder-target' }
  let(:custom_global_template_folder) { 'my-kbuilder-template' }
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
          config.target_folder_base = custom_target_folder_base
        }
      end

      it { is_expected.to eq(custom_target_folder_base) }
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
          config.global_template_folder = custom_global_template_folder
        }
      end

      it { is_expected.to eq(custom_global_template_folder) }
    end
  end
end
