# frozen_string_literal: true

RSpec.describe KBuilder::Configuration do
  let(:builder_module) { KBuilder }
  let(:cfg) { ->(config) {} }
  let(:instance) { builder_module.configuration }

  let(:custom_target_folder1) { '~/my-target-folder1' }
  let(:custom_target_folder2) { '~/my-target-folder2' }

  let(:expected_target_folder1) { File.expand_path(custom_target_folder1) }
  let(:expected_target_folder2) { File.expand_path(custom_target_folder2) }

  let(:custom_template_folder) { '~/my-template-folder' }
  let(:custom_domain_template_folder) { '~/my-template-folder-domain' }
  let(:custom_global_template_folder) { '~/my-template-folder-global' }

  let(:expected_template_folder) { File.expand_path(custom_template_folder) }
  let(:expected_domain_template_folder) { File.expand_path(custom_domain_template_folder) }
  let(:expected_global_template_folder) { File.expand_path(custom_global_template_folder) }

  before :each do
    builder_module.configure(&cfg)
  end
  after :each do
    builder_module.reset
  end

  describe '.target_folders' do
    subject { instance.target_folders.folders }

    context 'when not configured' do
      it { is_expected.to be_empty }
    end

    context 'when configured' do
      let(:cfg) do
        lambda { |config|
          config.target_folders.add(:src, custom_target_folder1)
          config.target_folders.add(:dst, custom_target_folder2)
        }
      end

      it do
        is_expected
          .to  include(src: expected_target_folder1)
          .and include(dst: expected_target_folder2)
      end
    end
  end

  describe '.template_folders' do
    subject { instance.template_folders }

    context 'when not configured' do
      it { is_expected.not_to be_nil }

      context '.ordered_keys' do
        subject { instance.template_folders.ordered_keys }

        it { is_expected.to be_empty }
      end

      context '.ordered_folders' do
        subject { instance.template_folders.ordered_folders }
      
        it { is_expected.to be_empty }
      end

      context '.folders' do
        subject { instance.template_folders.folders }
      
        it { is_expected.to be_empty }
      end
    end

    context 'when configured' do
      subject { instance.template_folders.ordered_folders }

      let(:cfg) do
        lambda { |config|
          config.template_folders.add(:global , custom_global_template_folder)
          config.template_folders.add(:domain , custom_domain_template_folder)
          config.template_folders.add(:app    , custom_template_folder)
        }
      end

      context '.ordered_keys' do
        subject { instance.template_folders.ordered_keys }

        it { is_expected.to eq([:app, :domain, :global]) }
      end

      context '.ordered_folders' do
        subject { instance.template_folders.ordered_folders }
      
        it { is_expected.to eq([expected_template_folder, expected_domain_template_folder, expected_global_template_folder]) }
      end

      context '.folders' do
        subject { instance.template_folders.folders }
      
        it do
          is_expected
            .to  include(:global => expected_global_template_folder)
            .and include(:domain => expected_domain_template_folder)
            .and include(:app => expected_template_folder)

          # [expected_template_folder, expected_domain_template_folder, expected_global_template_folder]
        end
      end
    end
  end

  describe '#to_h' do
    subject { instance.to_h }

    let(:cfg) do
      lambda { |config|
        config.target_folders.add(:src, custom_target_folder1)
        config.target_folders.add(:dst, custom_target_folder2)

        config.template_folders.add(:global , custom_global_template_folder)
        config.template_folders.add(:domain , custom_domain_template_folder)
        config.template_folders.add(:app    , custom_template_folder)
    }
    end

    it do
      is_expected
        .to be_a(Hash)
        .and have_key('target_folders')
        .and include('target_folders' => include(:src))
        .and include('target_folders' => include(:dst))
        .and have_key('target_folders')
        .and have_key('template_folders')
        .and include('template_folders' => include(:ordered))
        .and include('template_folders' => include(:global))
        .and include('template_folders' => include(:domain))
        .and include('template_folders' => include(:app))
    end
  end
end
