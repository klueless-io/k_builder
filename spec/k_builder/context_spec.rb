# frozen_string_literal: true

RSpec.describe KBuilder::Context do
  let(:builder_module) { KBuilder }
  let(:builder_config) { builder_module.configuration }

  let(:context_target_folder_base) { 'my-kbuilder-target' }
  let(:context_global_template_folder) { 'my-kbuilder-template' }
  # let(:cfg) { ->(config) {} }

  let(:context) { described_class.new(builder_module.configuration) }

  # before :each do
  #   builder_module.configure(&cfg)
  # end
  # after :each do
  #   builder_module.reset
  # end

  describe 'initialize from config' do
    describe '.target_folder_base' do
      subject { context.target_folder_base }
      it { is_expected.to eq(builder_config.target_folder_base) }

      context 'change target_folder_base' do
        before { context.target_folder_base = '/different/folder' }

        it { is_expected.to eq('/different/folder') }

        context 'config remains untouched' do
          subject { builder_config.target_folder_base }

          it { is_expected.not_to eq(context.target_folder_base) }
        end
      end
    end

    describe '.global_template_folder' do
      subject { context.global_template_folder }
      it { is_expected.to eq(builder_config.global_template_folder) }

      context 'change global_template_folder' do
        before { context.global_template_folder = '/different/folder' }

        it { is_expected.to eq('/different/folder') }

        context 'config remains untouched' do
          subject { builder_config.global_template_folder }

          it { is_expected.not_to eq(context.global_template_folder) }
        end
      end
    end
  end
end
