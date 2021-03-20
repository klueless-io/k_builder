# frozen_string_literal: true

RSpec.describe KBuilder::BaseBuilder do
  let(:instance) { described_class.init }
  let(:builder_module) { KBuilder }
  let(:cfg) { ->(config) {} }

  let(:sample_assets_folder) { File.join(Dir.getwd, 'spec', 'sample-assets') }

  let(:target_folder) { File.join(sample_assets_folder, 'target') }
  let(:target_documentation_folder) { File.join(sample_assets_folder, 'target-documentation') }

  let(:app_template_folder) { File.join(sample_assets_folder, 'app-template') }
  let(:domain_template_folder) { File.join(sample_assets_folder, 'domain-template') }
  let(:global_template_folder) { File.join(sample_assets_folder, 'global-template') }

  before :each do
    builder_module.configure(&cfg)
  end
  after :each do
    builder_module.reset
  end

  shared_context 'basic configuration' do
    let(:cfg) do
      lambda { |config|
        config.target_folders.add(:src, target_folder)
        config.template_folders.add(:global , global_template_folder)
      }
    end
  end

  shared_context 'complete configuration' do
    let(:cfg) do
      lambda { |config|
        config.target_folders.add(:src, target_folder)
        config.target_folders.add(:doc, target_documentation_folder)

        config.template_folders.add(:global , global_template_folder)
        config.template_folders.add(:domain, domain_template_folder)
        config.template_folders.add(:app , app_template_folder)
      }
    end
  end

  describe '#initialize' do
    subject { instance }

    let(:instance) { described_class.new }

    it { is_expected.not_to be_nil }

    context '.configuration' do
      subject { instance.configuration }

      it { is_expected.not_to be_nil }
    end
  end

  describe '#init' do
    subject { instance }

    it { is_expected.to be_a(described_class) }

    context 'with no configuration' do
      context '.target_folders.folders' do
        subject { instance.target_folders.folders }

        it { is_expected.to be_empty }
      end

      context '.target_folders.current' do
        subject { instance.target_folders.current }

        it { is_expected.to be_nil }
      end

      context '.template_folders.folders' do
        subject { instance.template_folders.folders }

        it { is_expected.to be_empty }
      end
    end

    context 'with basic configuration' do
      include_context 'basic configuration'

      context '.target_folders.folders' do
        subject { instance.target_folders.folders }

        it { is_expected.not_to be_empty }
      end

      context '.target_folders.current' do
        subject { instance.target_folders.current }

        it { is_expected.to eq(:src) }
      end

      context '.template_folders.folders' do
        subject { instance.template_folders.folders }

        it { is_expected.not_to be_empty }
      end
    end
  end

  describe '#set_current_folder (alias: cd)' do
    include_context 'complete configuration'

    describe '.current_folder_key' do
      subject { instance.current_folder_key }

      context 'when first initialized' do
        before { instance.cd(:src) }
        it { is_expected.to eq(:src) }
      end
      context 'when changed' do
        before { instance.cd(:doc) }
        it { is_expected.to eq(:doc) }
      end
    end

    describe '.get_target_folder with not paramaters' do
      subject { instance.get_target_folder }

      context 'when first initialized' do
        before { instance.cd(:src) }
        it { is_expected.to eq(target_folder) }
      end
      context 'when changed' do
        before { instance.cd(:doc) }
        it { is_expected.to eq(target_documentation_folder) }
      end
    end
  end

  describe '#build' do
    subject { described_class.build }

    it { expect { subject }.to raise_error NotImplementedError }
  end

  context 'accessors (fluent and non-fluent)' do
    # Target (NamedFolders)
    describe '#get_target_folder' do
      context 'when unknown' do
        subject { instance.get_target_folder(:yyy) }

        it { expect { subject }.to raise_error KBuilder::Error }
      end

      context 'when known' do
        include_context 'basic configuration'

        subject { instance.get_target_folder(:src) }

        it { is_expected.to eq(target_folder) }
      end
    end

    describe '#target_file' do
      include_context 'basic configuration'

      context 'when index.html' do
        subject { instance.target_file('index.html', folder: :src) }

        it { is_expected.to eq(File.join(target_folder, 'index.html')) }
      end

      context 'when img/logo.png' do
        subject { instance.target_file('img/index.html', folder: :src) }

        it { is_expected.to eq(File.join(target_folder, 'img/index.html')) }
      end

      context "when ['img', 'logo.png']" do
        subject { instance.target_file(['img', 'logo.png'], folder: :src) }

        it { is_expected.to eq(File.join(target_folder, 'img/logo.png')) }
      end
    end

    describe '#add_target_folder()' do
      context 'when known' do
        subject { instance.add_target_folder(:yyy, '~/yyy').get_target_folder(:yyy) }

        it { is_expected.to eq(File.expand_path('~/yyy')) }
      end
    end

    # Template (LayeredFolders)
    describe '#get_template_folder' do
      context 'when unknown' do
        subject { instance.get_template_folder(:yyy) }

        it { expect { subject }.to raise_error KBuilder::Error }
      end
    end

    context 'when known' do
      include_context 'basic configuration'

      subject { instance.get_template_folder(:global) }

      it { is_expected.to eq(global_template_folder) }
    end

    describe '#add_template_folder()' do
      context 'when known' do
        subject { instance.add_template_folder(:yyy, '~/yyy').get_template_folder(:yyy) }

        it { is_expected.to eq(File.expand_path('~/yyy')) }
      end
    end
  end
end
