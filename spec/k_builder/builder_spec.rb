# frozen_string_literal: true

RSpec.describe KBuilder::Builder do
  let(:builder_module) { KBuilder }
  let(:cfg) { ->(config) {} }

  before :each do
    builder_module.configure(&cfg)
  end
  after :each do
    builder_module.reset
  end

  describe '#initialize' do
    subject { described_class.new }

    context 'with default configuration' do
      it { is_expected.not_to be_nil }
    end
  end

  describe '#init' do
    subject { described_class.init }

    it { is_expected.to be_a(described_class) }

    describe '.hash' do
      subject { described_class.init(config).hash }

      context 'with default configuration' do
        let(:config) { nil }

        it do
          is_expected
            .to  be_a(Hash)
            .and include('target_folder' => builder_module.configuration.target_folder)
            .and include('template_folder' => builder_module.configuration.template_folder)
            .and include('template_folder_global' => builder_module.configuration.template_folder_global)
        end
      end

      context 'with custom configuration' do
        context 'when empty' do
          let(:config) { {} }

          it { is_expected.to eq({}) }
        end

        context 'when configured with nil' do
          let(:config) do
            {
              'target_folder' => nil,
              'template_folder' => nil,
              'template_folder_global' => nil
            }
          end

          it do
            is_expected
              .to  be_a(Hash)
              .and include('target_folder' => be_nil)
              .and include('template_folder' => be_nil)
              .and include('template_folder_global' => be_nil)
          end
        end

        context 'when configured with nil' do
          let(:config) do
            {
              'target_folder' => '/xmen',
              'template_folder' => '/xmen',
              'template_folder_global' => '/xmen'
            }
          end

          it do
            is_expected
              .to  be_a(Hash)
              .and include('target_folder' => eq('/xmen'))
              .and include('template_folder' => eq('/xmen'))
              .and include('template_folder_global' => eq('/xmen'))
          end
        end

        context 'when configured with nil' do
          let(:config) do
            {
              'target_folder' => '~/xmen',
              'template_folder' => '~/xmen',
              'template_folder_global' => '~/xmen'
            }
          end

          it do
            is_expected
              .to  be_a(Hash)
              .and include('target_folder' => eq(File.expand_path('~/xmen')))
              .and include('template_folder' => eq(File.expand_path('~/xmen')))
              .and include('template_folder_global' => eq(File.expand_path('~/xmen')))
          end
        end
      end
    end
  end

  describe '#build' do
    subject { described_class.build }
    context 'with default configuration' do
      it do
        is_expected
          .to  be_a(Hash) # Child class may return a DryStruct or OpenStruct
          .and include('target_folder' => builder_module.configuration.target_folder)
          .and include('template_folder' => builder_module.configuration.template_folder)
          .and include('template_folder_global' => builder_module.configuration.template_folder_global)
      end
    end
  end

  context 'custom setter / getters' do
    describe '#set_target_folder (fluent setter) / .target_folder (plain get)' do
      subject { described_class.init({}).set_target_folder('~/yyy').target_folder }

      it { is_expected.to eq(File.expand_path('~/yyy')) }
    end

    describe '#set_template_folder (fluent setter) / .template_folder (plain get)' do
      subject { described_class.init({}).set_template_folder('~/yyy').template_folder }

      it { is_expected.to eq(File.expand_path('~/yyy')) }
    end

    describe '#set_template_folder_global (fluent setter) / .template_folder_global (plain get)' do
      subject { described_class.init({}).set_template_folder_global('~/yyy').template_folder_global }

      it { is_expected.to eq(File.expand_path('~/yyy')) }
    end
  end

  describe 'target_path' do
    subject { described_class.new.set_target_folder(folder).target_file('abc.txt') }

    let(:folder) { '/xmen' }

    it { is_expected.to eq('/xmen/abc.txt') }

    context 'with expanded path' do
      let(:folder) { '~/xmen' }

      it { is_expected.to eq(File.join(File.expand_path('~/xmen'), 'abc.txt')) }
    end
  end
end
