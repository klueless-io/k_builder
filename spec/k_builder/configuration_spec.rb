# frozen_string_literal: true

RSpec.describe KBuilder::Configuration do
  let(:builder_module) { KBuilder }
  let(:cfg) { ->(config) {} }

  let(:custom_target_folder) { '~/my-target-folder' }
  let(:custom_template_folder) { '~/my-template-folder' }
  let(:custom_global_template_folder) { '~/my-template-folder-global' }

  before :each do
    builder_module.configure(&cfg)
  end
  after :each do
    builder_module.reset
  end

  describe '.target_folder' do
    subject { builder_module.configuration.target_folder }

    context 'when not configured' do
      it { is_expected.to eq(Dir.getwd) }
    end

    context 'when configured' do
      let(:cfg) do
        lambda { |config|
          config.target_folder = custom_target_folder
        }
      end

      it { is_expected.to eq(custom_target_folder) }
    end
  end

  describe '.template_folder' do
    subject { builder_module.configuration.template_folder }

    context 'when not configured' do
      it { is_expected.to eq(File.join(Dir.getwd, '.templates')) }
    end

    context 'when configured' do
      let(:cfg) do
        lambda { |config|
          config.template_folder = custom_template_folder
        }
      end

      it { is_expected.to eq(custom_template_folder) }
    end
  end

  describe '.global_template_folder' do
    subject { builder_module.configuration.global_template_folder }

    context 'when not configured' do
      it { is_expected.to be_nil }
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

  describe '#as_hash' do
    subject { builder_module.configuration }

    it do
      is_expected
        .to  include('target_folder' => builder_module.configuration.target_folder)
        .and include('template_folder' => builder_module.configuration.template_folder)
        .and include('global_template_folder' => builder_module.configuration.global_template_folder)
    end
  end
end
