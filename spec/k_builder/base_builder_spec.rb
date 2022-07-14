# frozen_string_literal: true

RSpec.describe KBuilder::BaseBuilder do
  let(:instance) { described_class.init }
  let(:k_config) { KConfig }
  let(:cfg) { ->(config) {} }

  let(:sample_assets_folder) { File.join(Dir.getwd, 'spec', 'sample-assets') }
  let(:sample_file) { 'some-text.txt' } # { File.join(sample_assets_folder, 'some-text.txt') }

  let(:target_folder) { File.join(sample_assets_folder, 'target') }
  let(:target_documentation_folder) { File.join(sample_assets_folder, 'target-documentation') }

  let(:app_template_folder) { File.join(sample_assets_folder, 'app-template') }
  let(:domain_template_folder) { File.join(sample_assets_folder, 'domain-template') }
  let(:global_template_folder) { File.join(sample_assets_folder, 'global-template') }

  before :each do
    k_config.configure(&cfg)
  end
  after :each do
    k_config.reset
  end

  shared_context 'temp_dir' do
    include_context :use_temp_folder

    let(:cfg) do
      lambda { |config|
        config.target_folders.add(:src, @temp_folder)
        config.target_folders.add(:src_child, :src, 'child')
      }
    end
  end

  shared_context 'temp_dir + templates configuration' do
    include_context :use_temp_folder

    let(:cfg) do
      lambda { |config|
        config.target_folders.add(:src, @temp_folder)
        config.target_folders.add(:src_child, :src, 'child')

        config.template_folders.add(:global , global_template_folder)
        config.template_folders.add(:domain, domain_template_folder)
        config.template_folders.add(:app , app_template_folder)
      }
    end
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

  # context 'debug' do
  #   include_context 'complete configuration'

  #   it { instance.debug }
  # end

  describe '#init' do
    subject { instance }

    it { is_expected.to be_a(described_class) }

    context '.last_output_file' do
      subject { instance.last_output_file }

      it { is_expected.to be_nil }
    end

    context '.last_template_file' do
      subject { instance.last_template_file }

      it { is_expected.to be_nil }
    end

    context '.last_output_folder' do
      subject { instance.last_output_folder }

      it { is_expected.to be_nil }
    end

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

  describe '#set_current_folder' do
    subject { instance.set_current_folder_action(folder_key) }

    let(:file) { 'my-file.txt' }
    let(:folder_key) { :xmen }

    it do
      is_expected.to eq({
                          action: :set_current_folder,
                          folder_key: folder_key,
                          played: false
                        })
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

    describe '.target_folder with not paramaters' do
      subject { instance.target_folder }

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

  describe '#find_template_file' do
    include_context 'complete configuration'

    subject { instance.find_template_file(file) }

    let(:file) { 'bad-file.txt' }

    context 'with file not found in either store' do
      it { is_expected.to be_nil }
    end

    context 'with file in both local and global folder' do
      let(:file) { 'template1.txt' }

      it { is_expected.to eq(File.join(app_template_folder, file)) }
    end

    context 'with file in both domain and global folder' do
      let(:file) { 'template2.txt' }

      it { is_expected.to eq(File.join(domain_template_folder, file)) }
    end

    context 'with file only in global folder' do
      let(:file) { 'template3.txt' }

      it { is_expected.to eq(File.join(global_template_folder, file)) }
    end

    context 'with file with deep path' do
      let(:file) { ['abc', 'xyz', 'deep-template.txt'] }

      it { is_expected.to eq(File.join(global_template_folder, file)) }
    end
  end

  describe '#build' do
    subject { described_class.build }

    it { expect { subject }.to raise_error NotImplementedError }
  end

  context 'accessors (fluent and non-fluent)' do
    # Target (NamedFolders)
    describe '#target_folder' do
      context 'when unknown' do
        subject { instance.target_folder(:yyy) }

        it { expect { subject }.to raise_error KType::Error }
      end

      context 'when known' do
        include_context 'basic configuration'

        subject { instance.target_folder(:src) }

        it { is_expected.to eq(target_folder) }
      end
    end

    describe '#target_file' do
      context 'with folder key supplied' do
        include_context 'basic configuration'

        context 'relative files' do
          context 'when simple file "index.html"' do
            subject { instance.target_file('index.html', folder_key: :src) }

            it { is_expected.to eq(File.join(target_folder, 'index.html')) }
          end

          context 'when file is relative to folder "img/logo.png"' do
            subject { instance.target_file('img/index.html', folder_key: :src) }

            it { is_expected.to eq(File.join(target_folder, 'img/index.html')) }
          end

          context 'when file is relative to folder as file_parts "img", "logo.png"' do
            subject { instance.target_file('img', 'logo.png', folder_key: :src) }

            it { is_expected.to eq(File.join(target_folder, 'img/logo.png')) }
          end
        end

        context 'files relative to folder' do
          include_context 'complete configuration'

          context 'when index.html in default folder' do
            subject { instance.target_file('index.html') }

            it { is_expected.to eq(File.join(target_folder, 'index.html')) }
          end

          context 'when readme.md after change folder' do
            before { instance.cd(:doc) }

            subject { instance.target_file('readme.md') }

            it { is_expected.to eq(File.join(target_documentation_folder, 'readme.md')) }
          end
        end

        context 'absolute files' do
          context 'file is absolute "/a/b/c.txt"' do
            subject { instance.target_file(File.join(target_documentation_folder, 'some-documentation_absolute.txt')) }

            it { is_expected.to eq(File.join(target_documentation_folder, 'some-documentation_absolute.txt')) }
          end
        end
      end
    end

    describe '#add_target_folder()' do
      context 'when known' do
        subject { instance.add_target_folder(:yyy, '~/yyy').target_folder(:yyy) }

        it { is_expected.to eq(File.expand_path('~/yyy')) }
      end
    end

    # Template (LayeredFolders)
    describe '#get_template_folder' do
      context 'when unknown' do
        subject { instance.get_template_folder(:yyy) }

        it { expect { subject }.to raise_error KType::Error }
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

  describe '#use_content' do
    subject { instance.use_content(**opts) }

    context 'with :unhandled option' do
      let(:opts) { {} }

      it { is_expected.to be_nil }
    end

    context 'with :content' do
      let(:opts) { { content: 'Content is supplied and passed through in one action' } }

      it { is_expected.to eq('Content is supplied and passed through in one action') }
    end

    context 'with :content_file' do
      include_context 'complete configuration'

      let(:opts) { { content_file: sample_file } }

      it { is_expected.to eq('Some text from a text file') }
    end
  end

  describe '#use_template' do
    subject { instance.use_template(**opts) }

    let(:file) { 'bad-file.txt' }

    context 'with :unhandled option' do
      let(:opts) { {} }

      it { is_expected.to be_nil }
    end

    context 'with :template' do
      let(:opts) { { template: 'Hello {{name}}' } }

      it { is_expected.to eq('Hello {{name}}') }
    end

    context 'with :template_file' do
      include_context 'complete configuration'

      context 'when file not found' do
        let(:opts) { { template_file: file } }
        let(:file) { 'bad-file.txt' }

        it { is_expected.to eq('template not found: bad-file.txt') }
      end

      context 'when template exists in app and global folder' do
        let(:opts) { { template_file: file } }
        let(:file) { 'template1.txt' }

        it { is_expected.to eq('App template 1 - Hello {{name}}') }
      end

      context 'when template exists only in the global folder' do
        include_context 'complete configuration'
        let(:opts) { { template_file: file } }
        let(:file) { 'template3.txt' }

        it { is_expected.to eq('Global template 3 - Hello {{name}}') }
      end
    end
  end

  describe '#process_any_content' do
    include_context 'complete configuration'

    subject { instance.process_any_content(**opts) }

    let(:opts) { {} }

    it { is_expected.to be_nil }

    context 'with :content' do
      let(:opts) { { content: 'Content is supplied and passed through in one action' } }

      it { is_expected.to eq('Content is supplied and passed through in one action') }
    end

    context 'with :content_file' do
      let(:opts) { { content_file: file } }
      let(:file) { sample_file }

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

    context 'with :template_file (template3 exists in global folder only)' do
      let(:opts) { { template_file: file, name: 'Dave' } }
      let(:file) { 'template3.txt' }

      it { is_expected.to eq('Global template 3 - Hello Dave') }
    end
  end

  describe '#add_file_action' do
    subject { instance.add_file_action(file, **opts) }

    let(:file) { 'my-file.txt' }
    let(:opts) { { folder_key: :xmen } }

    it do
      is_expected.to eq({
                          action: :add_file,
                          file: file,
                          opts: opts,
                          played: false
                        })
    end
  end

  describe '#add_file' do
    include_context 'temp_dir + templates configuration'

    before { instance.add_file(file, **opts) }

    let(:file) { 'my-file.txt' }
    let(:target_file) { File.join(@temp_folder, file) }
    let(:opts) { {} }

    context 'file is created' do
      subject { File.exist?(target_file) }

      it { is_expected.to be_truthy }
    end

    context 'when :folder_key is specified' do
      subject { File.exist?(target_file) }

      let(:opts) { { folder_key: :src_child } }
      let(:target_file) { File.join(@temp_folder, 'child', file) }

      it { is_expected.to be_truthy }
    end

    context 'validate file contents' do
      subject { File.read(target_file).strip }

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
        let(:opts) { { content_file: sample_file } }

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

      context 'when template_file: "template3.txt"' do
        let(:opts) { { template_file: 'template3.txt', name: 'Dave in Global Template' } }

        it { is_expected.to eq('Global template 3 - Hello Dave in Global Template') }
      end

      context 'when prettier is applied' do
        let(:opts) { { content: '<h1>make me</h1><p>pretty</p>', pretty: true } }
        let(:file) { 'make-pretty.html' }

        it do
          expected = <<~HTML.strip
            <h1>make me</h1>
            <p>pretty</p>
          HTML

          is_expected.to eq(expected)
        end
      end
    end

    describe '#make_folder' do
      include_context 'temp_dir'

      subject { Dir.exist?(expected_path) }

      before { instance.make_folder(folder_key, sub_path: sub_path) }

      let(:folder_key) { nil }
      let(:sub_path) { nil }
      let(:expected_path) { @temp_folder }

      context 'when current folder_key' do
        it { is_expected.to be_truthy }
      end

      context 'when subpath for current folder_key' do
        let(:expected_path) { File.join(@temp_folder, sub_path) }
        let(:sub_path) { 'xyz' }

        it { is_expected.to be_truthy }
      end

      context 'when changing folder_key' do
        let(:folder_key) { :src_child }
        let(:expected_path) { File.join(@temp_folder, 'child') }

        it { is_expected.to be_truthy }
      end

      context 'when changing folder_key and adding subpath' do
        let(:folder_key) { :src_child }
        let(:sub_path) { 'abc/xyz' }
        let(:expected_path) { File.join(@temp_folder, 'child', sub_path) }

        it { is_expected.to be_truthy }
      end
    end

    context '$T$ variable interpolation' do
      let(:file) { 'my-file.txt' }

      # $T_FILE$        = 'abc/xyz/deep-template.txt'
      # $T_PATH$        = 'abc/xyz'
      # $T_FILE_NAME$   = 'deep-template.txt'
      let(:opts) { { template_file: ['abc', 'xyz', 'deep-template.txt'] } }

      let(:target_file) { File.join(@temp_folder, file) }
    end
  end

  describe '#delete_file_action' do
    subject { instance.delete_file_action(file, **opts) }

    let(:file) { 'my-file.txt' }
    let(:opts) { { folder_key: :xmen } }

    it do
      is_expected.to eq({
                          action: :delete_file,
                          file: file,
                          opts: opts,
                          played: false
                        })
    end
  end

  describe '#delete_file' do
    include_context 'temp_dir + templates configuration'

    before { instance.add_file(file) }

    let(:file) { 'my-file.txt' }
    let(:target_file) { File.join(@temp_folder, file) }

    context 'when file exists' do
      subject { File.exist?(target_file) }

      it { is_expected.to be_truthy }

      context 'after delete_file' do
        before { instance.delete_file(file) }

        it { is_expected.to be_falsey }
      end
    end
  end

  describe '#add_clipboard_action' do
    subject { instance.add_clipboard_action(**opts) }

    let(:opts) { { template_file: 'abc' } }

    it do
      is_expected.to eq({
                          action: :add_clipboard,
                          opts: opts,
                          played: false
                        })
    end
  end

  # describe '#add_clipboard (not supported in CI)' do
  #   include_context 'complete configuration'

  #   before { instance.add_clipboard(**opts) }

  #   let(:opts) { {} }

  #   context 'validate file contents' do
  #     subject { pbpaste }

  #     context 'when no options provided, this is the equivalent of writing empty' do
  #       it { is_expected.to eq('') }
  #     end

  #     context 'when content: "I am some content"' do
  #       let(:opts) { { content: 'I am some content' } }

  #       it { is_expected.to eq('I am some content') }
  #     end

  #     context 'when content: "Hello {{name}}"' do
  #       let(:opts) { { content: 'Hello {{name}}' } }

  #       it { is_expected.to eq('Hello {{name}}') }
  #     end

  #     context 'when content_file: "some-text.txt"' do
  #       let(:opts) { { content_file: sample_file } }

  #       it { is_expected.to eq('Some text from a text file') }
  #     end

  #     context 'when template: "Hello {{name}}"' do
  #       let(:opts) { { template: 'Hello {{name}}', name: 'Dave' } }

  #       it { is_expected.to eq('Hello Dave') }
  #     end

  #     context 'when template_file: "template1.txt"' do
  #       let(:opts) { { template_file: 'template1.txt', name: 'Dave in Local Template' } }

  #       it { is_expected.to eq('App template 1 - Hello Dave in Local Template') }
  #     end

  #     context 'when template_file: "template3.txt"' do
  #       let(:opts) { { template_file: 'template3.txt', name: 'Dave in Global Template' } }

  #       it { is_expected.to eq('Global template 3 - Hello Dave in Global Template') }
  #     end
  #   end
  # end

  describe '#run_cop' do
    include_context 'temp_dir + templates configuration'

    subject { File.read(target_file).strip }

    before do
      instance
        .add_file(file_name, content: content)
        .run_cop(target_file, fix_safe: fix_safe, fix_unsafe: fix_unsafe)
    end

    let(:target_file) { File.join(@temp_folder, file_name) }
    let(:file_name) { 'make-pretty.rb' }
    let(:fix_safe) { false }
    let(:fix_unsafe) { false }
    let(:content) { "class David\ndef initialize(abc); @abc=abc; end\nend" }

    context 'when log only' do
      it {
        expected = <<~RUBY.strip
          class David
          def initialize(abc); @abc=abc; end
          end
        RUBY

        is_expected.to eq(expected)
      }
    end

    context 'when safe auto fix (-a)' do
      let(:fix_safe) { true }

      it {
        expected = <<~RUBY.strip
          class David
            def initialize(abc)
              @abc = abc
            end
          end
        RUBY

        is_expected.to eq(expected)
      }
    end

    context 'when safe auto fix (-A)' do
      let(:fix_unsafe) { true }

      it {
        expected = <<~RUBY.strip
          # frozen_string_literal: true

          class David
            def initialize(abc)
              @abc = abc
            end
          end
        RUBY

        is_expected.to eq(expected)
      }
    end
  end

  describe '#run_prettier' do
    include_context 'temp_dir + templates configuration'

    subject { File.read(target_file).strip }

    before do
      instance
        .add_file(file_name, content: content)
        .run_prettier(file_name, log_level: :debug)
    end

    let(:target_file) { File.join(@temp_folder, file_name) }

    context 'when css file' do
      let(:file_name) { 'make-pretty.css' }
      let(:content) { '{.my-color { color: red;} }' }

      it {
        expected = <<~CSS.strip
          {
            .my-color {
              color: red;
            }
          }
        CSS

        is_expected.to eq(expected)
      }
    end

    context 'when js file' do
      let(:file_name) { 'make-pretty.js' }
      let(:content) { 'function Dave() { console.log("was here") }' }

      it {
        expected = <<~JAVASCRIPT.strip
          function Dave() {
            console.log("was here");
          }
        JAVASCRIPT

        is_expected.to eq(expected)
      }
    end

    # NOTE: it is better to use cop for ruby files
    # NOTE: and it stopped working (maybe a configuration issue)
    # context 'when rb file' do
    #   let(:file_name) { 'make-pretty.rb' }
    #   let(:content) { 'class David; def initialize(abc); @abc=abc; end; end;' }

    #   it {
    #     expected = <<~RUBY.strip
    #       class David
    #         def initialize(abc)
    #           @abc = abc
    #         end
    #       end
    #     RUBY

    #     is_expected.to eq(expected)
    #   }
    # end

    context 'when html file' do
      let(:file_name) { 'make-pretty.html' }
      let(:content) { '<h1>David</h1><p>Was Here</p>   <p>and here</p>' }

      it do
        expected = <<~HTML.strip
          <h1>David</h1>
          <p>Was Here</p>
          <p>and here</p>
        HTML

        is_expected.to eq(expected)
      end
    end
  end

  describe '#run_command_action' do
    subject { instance.run_command_action(command) }

    let(:command) { "echo 'hello'" }

    it do
      is_expected.to eq({
                          action: :run_command,
                          command: command,
                          played: false
                        })
    end
  end

  describe '#vscode_action' do
    subject { instance.vscode_action(*file_parts, **opts) }

    let(:file_parts) { ['xmen', 'my-file.txt'] }
    let(:opts) { { folder_key: :xmen, file: nil } }

    it do
      is_expected.to eq({
                          action: :vscode,
                          file_parts: file_parts,
                          opts: opts,
                          played: false
                        })
    end
  end

  describe '#vscode' do
    include_context 'complete configuration'

    context 'functional tests, do not run in production' do
      # context 'relative file parts to current folder' do
      #   subject { instance.cd(:src).vscode('config', 'some-file.txt') }

      #   it { subject }
      # end

      # context 'relative file parts to different folder' do
      #   subject { instance.vscode('some-documentation.txt', folder: :doc) }

      #   it { subject }
      # end

      # context 'absolute file' do
      #   subject { instance.vscode(File.join(target_documentation_folder, 'some-documentation_absolute.txt')) }

      #   it { subject }
      # end
    end

    # context 'when browse, open, open_template and pause' do
    #   before { instance.add_file(file, **opts) }

    #   let(:file) { 'my-file.txt' }
    #   let(:opts) { { template_file: 'template1.txt', name: 'Dave in Local Template', open: true, open_template: true, browse: true, pause: 2 } }

    #   it { subject }
    # end
  end

  describe '#browse_action' do
    subject { instance.browse_action(*file_parts, **opts) }

    let(:file_parts) { ['xmen', 'my-file.txt'] }
    let(:opts) { { folder_key: :xmen, file: nil } }

    it do
      is_expected.to eq({
                          action: :browse,
                          file_parts: file_parts,
                          opts: opts,
                          played: false
                        })
    end
  end

  def pbpaste
    `pbpaste`
  end
end
