# frozen_string_literal: true

RSpec.describe KBuilder::Builder do
  let(:builder_module) { KBuilder }
  let(:cfg) { ->(config) {} }
  let(:builder) { described_class.new }

  let(:samples_folder) { File.join(Dir.getwd, 'spec', 'samples') }
  let(:app_template_folder) { File.join(Dir.getwd, 'spec', 'samples', 'app-template') }
  let(:global_template_folder) { File.join(Dir.getwd, 'spec', 'samples', 'global-template') }

  before :each do
    builder_module.configure(&cfg)
  end
  after :each do
    builder_module.reset
  end

  describe '#initialize' do
    subject { builder }

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
            .and include('global_template_folder' => builder_module.configuration.global_template_folder)
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
              'global_template_folder' => nil
            }
          end

          it do
            is_expected
              .to  be_a(Hash)
              .and include('target_folder' => be_nil)
              .and include('template_folder' => be_nil)
              .and include('global_template_folder' => be_nil)
          end
        end

        context 'when configured with nil' do
          let(:config) do
            {
              'target_folder' => '/xmen',
              'template_folder' => '/xmen',
              'global_template_folder' => '/xmen'
            }
          end

          it do
            is_expected
              .to  be_a(Hash)
              .and include('target_folder' => eq('/xmen'))
              .and include('template_folder' => eq('/xmen'))
              .and include('global_template_folder' => eq('/xmen'))
          end
        end

        context 'when configured with nil' do
          let(:config) do
            {
              'target_folder' => '~/xmen',
              'template_folder' => '~/xmen',
              'global_template_folder' => '~/xmen'
            }
          end

          it do
            is_expected
              .to  be_a(Hash)
              .and include('target_folder' => eq(File.expand_path('~/xmen')))
              .and include('template_folder' => eq(File.expand_path('~/xmen')))
              .and include('global_template_folder' => eq(File.expand_path('~/xmen')))
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
          .and include('global_template_folder' => builder_module.configuration.global_template_folder)
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

    describe '#set_global_template_folder (fluent setter) / .global_template_folder (plain get)' do
      subject { described_class.init({}).set_global_template_folder('~/yyy').global_template_folder }

      it { is_expected.to eq(File.expand_path('~/yyy')) }
    end
  end

  describe '#target_file' do
    subject { builder.set_target_folder(folder).target_file('abc.txt') }

    let(:folder) { '/xmen' }

    it { is_expected.to eq('/xmen/abc.txt') }

    context 'with expanded path' do
      let(:folder) { '~/xmen' }

      it { is_expected.to eq(File.join(File.expand_path('~/xmen'), 'abc.txt')) }
    end
  end

  describe '#template_file' do
    subject { builder.set_template_folder(folder).template_file('abc.txt') }

    let(:folder) { '/xmen' }

    it { is_expected.to eq('/xmen/abc.txt') }

    context 'with expanded path' do
      let(:folder) { '~/xmen' }

      it { is_expected.to eq(File.join(File.expand_path('~/xmen'), 'abc.txt')) }
    end
  end

  describe '#global_template_file' do
    subject { builder.set_global_template_folder(folder).global_template_file('abc.txt') }

    let(:folder) { '/xmen' }

    it { is_expected.to eq('/xmen/abc.txt') }

    context 'with expanded path' do
      let(:folder) { '~/xmen' }

      it { is_expected.to eq(File.join(File.expand_path('~/xmen'), 'abc.txt')) }
    end
  end

  describe '#find_template_file' do
    subject do
      described_class
        .new
        .set_template_folder(app_template_folder)
        .set_global_template_folder(global_template_folder)
        .find_template_file(file)
    end

    let(:file) { 'bad-file.txt' }

    context 'with file not found in either store' do
      it { is_expected.to be_nil }
    end

    context 'with file in both local and global folder' do
      let(:file) { 'template1.txt' }

      it { is_expected.to eq(File.join(app_template_folder, file)) }
    end

    context 'with file only in global folder' do
      let(:file) { 'template2.txt' }

      it { is_expected.to eq(File.join(global_template_folder, file)) }
    end
  end

  describe '#use_content' do
    subject { builder.use_content(**opts) }

    context 'with :unhandled option' do
      let(:opts) { {} }

      it { is_expected.to be_nil }
    end

    context 'with :content' do
      let(:opts) { { content: 'Content is supplied and passed through in one action' } }

      it { is_expected.to eq('Content is supplied and passed through in one action') }
    end

    context 'with :content_file' do
      let(:opts) { { content_file: file } }
      let(:file) { builder.set_target_folder(Dir.getwd).target_file('spec/samples/some-text.txt') }

      it { is_expected.to eq('Some text from a text file') }
    end
  end

  describe '#use_template' do
    subject do
      described_class
        .new
        .set_template_folder(app_template_folder)
        .set_global_template_folder(global_template_folder)
        .use_template(**opts)
    end

    let(:file) { 'bad-file.txt' }

    context 'with :unhandled option' do
      let(:opts) { {} }

      it { is_expected.to be_nil }
    end

    context 'with :template' do
      let(:opts) { { template: 'Hello {{name}}' } }

      it { is_expected.to eq('Hello {{name}}') }
    end

    context 'with :template_file (file not found)' do
      let(:opts) { { template_file: file } }
      let(:file) { 'bad-file.txt' }

      it { is_expected.to eq('template not found: bad-file.txt') }
    end

    context 'with :template_file (template1 exists in app and global folder)' do
      let(:opts) { { template_file: file } }
      let(:file) { 'template1.txt' }

      it { is_expected.to eq('App template 1 - Hello {{name}}') }
    end

    context 'with :template_file (template2 exists in global folder only)' do
      let(:opts) { { template_file: file } }
      let(:file) { 'template2.txt' }

      it { is_expected.to eq('Global template 2 - Hello {{name}}') }
    end
  end

  describe '#process_any_content' do
    subject do
      builder
        .set_target_folder(Dir.getwd)
        .set_template_folder(app_template_folder)
        .set_global_template_folder(global_template_folder)
        .process_any_content(**opts)
    end

    let(:app_template_folder) { File.join(Dir.getwd, 'spec', 'samples', 'app-template') }
    let(:global_template_folder) { File.join(Dir.getwd, 'spec', 'samples', 'global-template') }

    let(:opts) { {} }

    it { is_expected.to be_nil }

    context 'with :content' do
      let(:opts) { { content: 'Content is supplied and passed through in one action' } }

      it { is_expected.to eq('Content is supplied and passed through in one action') }
    end

    context 'with :content_file' do
      let(:opts) { { content_file: file } }
      let(:file) { builder.target_file('spec/samples/some-text.txt') }

      it { is_expected.to eq('Some text from a text file') }
    end

    context 'with :template' do
      let(:opts) { { template: 'Hello {{name}}', name: 'Dave' } }

      it { is_expected.to eq('Hello Dave') }
    end

    context 'with :template_file (file not found)' do
      let(:opts) { { template_file: file, name: 'Dave' } }
      let(:file) { 'bad-file.txt' }

      it { is_expected.to eq('template not found: bad-file.txt') }
    end

    context 'with :template_file (template1 exists in app and global folder)' do
      let(:opts) { { template_file: file, name: 'Dave' } }
      let(:file) { 'template1.txt' }

      it { is_expected.to eq('App template 1 - Hello Dave') }
    end

    context 'with :template_file (template2 exists in global folder only)' do
      let(:opts) { { template_file: file, name: 'Dave' } }
      let(:file) { 'template2.txt' }

      it { is_expected.to eq('Global template 2 - Hello Dave') }
    end
  end

  describe '#add_file' do
    include_context :use_temp_folder

    before do
      builder
        .set_target_folder(@temp_folder)
        .set_template_folder(app_template_folder)
        .set_global_template_folder(global_template_folder)
        .add_file('my-file.txt', **opts)
    end

    let(:file) { 'my-file.txt' }
    let(:target_file) { File.join(@temp_folder, file) }
    let(:opts) { {} }

    context 'file is created' do
      subject { File.exist?(target_file) }

      it { is_expected.to eq(true) }
    end

    context 'validate file contents' do
      subject { File.read(target_file) }

      context 'when no options provided, this is the equivalent of first touch' do
        it { is_expected.to eq('') }
      end

      context 'when content: "I am some content"' do
        let(:opts) { { content: 'I am some content' } }

        it { is_expected.to eq('I am some content') }
      end

      context 'when content: "Hello {{name}}"' do
        let(:opts) { { content: 'Hello {{name}}' } }

        it { is_expected.to eq('Hello {{name}}') }
      end

      context 'when content_file: "some-text.txt"' do
        let(:opts) { { content_file: File.join(samples_folder, 'some-text.txt') } }

        it { is_expected.to eq('Some text from a text file') }
      end

      context 'when template: "Hello {{name}}"' do
        let(:opts) { { template: 'Hello {{name}}', name: 'Dave' } }

        it { is_expected.to eq('Hello Dave') }
      end

      context 'when template_file: "template1.txt"' do
        let(:opts) { { template_file: 'template1.txt', name: 'Dave in Local Template' } }

        it { is_expected.to eq('App template 1 - Hello Dave in Local Template') }
      end

      context 'when template_file: "template2.txt"' do
        let(:opts) { { template_file: 'template2.txt', name: 'Dave in Global Template' } }

        it { is_expected.to eq('Global template 2 - Hello Dave in Global Template') }
      end
    end
  end

  describe '#prettier' do
    include_context :use_temp_folder
    subject do
      builder
        .set_target_folder(File.join(Dir.getwd, 'spec', 'samples'))
        .add_file(content: '{.my-color { color: red;} }')
        .run_prettier(file)
    end

    it { puts @temp_folder }

    # context 'process css from source to target' do
    #   let(:file) { 'make-me-pretty.css' }

    #   fit {
    #     subject

    #     expected = <<~CSS
    #     {
    #       .my-color {
    #         color: red;
    #       }
    #     }
    #     CSS
    #   }

    # end
  end
end
