# frozen_string_literal: true

RSpec.describe KBuilder::Configuration do
  let(:builder_module) { KBuilder }
  let(:cfg) { ->(config) {} }
  let(:instance) { builder_module.configuration }

  let(:custom_target_folder) { '~/my-target-folder' }
  let(:custom_template_folder) { '~/my-template-folder' }
  let(:custom_global_template_folder) { '~/my-template-folder-global' }

  before :each do
    builder_module.configure(&cfg)
  end
  after :each do
    builder_module.reset
  end

  describe '.template_folder' do
    subject { instance.template_folder }

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
    subject { instance.global_template_folder }

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
    subject { instance.to_hash }

    it do
      is_expected
        .to  include('target_folder' => instance.target_folder)
        .and include('template_folder' => instance.template_folder)
        .and include('global_template_folder' => instance.global_template_folder)
    end
  end

  # context 'extend configuration via third parties' do
  #   subject { instance }

  #   it { is_expected.not_to be_nil }

  #   it { is_expected.to be_a(KBuilder::Configuration).and respond_to(:third_party) }

  #   context 'third party is attached' do
  #     subject { instance.third_party }

  #     it do
  #       is_expected
  #         .to  be_a(KBuilder::ThirdParty::Configuration)
  #         .and respond_to(:aaa)
  #         .and respond_to(:bbb)
  #         .and respond_to(:ccc)
  #     end
  #   end

  #   context 'configure' do
  #     let(:cfg) do
  #       lambda { |config|
  #         config.template_folder = custom_template_folder
  #         config.template_folder = custom_template_folder
  #         config.global_template_folder = custom_global_template_folder
  #         config.third_party.aaa = '1'
  #         config.third_party.bbb = '2'
  #         config.third_party.ccc = '3'
  #       }
  #     end

  #     describe '#as_hash' do
  #       subject { instance.to_hash }

  #       it do
  #         is_expected
  #           .to  include('target_folder' => instance.target_folder)
  #           .and include('template_folder' => instance.template_folder)
  #           .and include('global_template_folder' => instance.global_template_folder)
  #           .and include('third_party' => include('aaa' => '1'))
  #           .and include('third_party' => include('bbb' => '2'))
  #           .and include('third_party' => include('ccc' => '3'))
  #       end
  #     end
  #   end
  # end
end
