# frozen_string_literal: true

RSpec.describe KBuilder::Commands::RuboCopCommand do
  # Command setup
  let(:instance)          { described_class.new(file_pattern, **opts) }
  let(:file_pattern)      { target_file }
  let(:opts)              { {} }

  # Builder setup (dependency)
  let(:builder)           { KBuilder::BaseBuilder.init }
  let(:builder_module)    { KBuilder }
  let(:cfg)               { ->(config) {} }

  # Input parameter (dependencies)
  let(:rubo_config_file)  { File.expand_path('spec/sample-assets/.sample-rubocop.yaml') }
  let(:target_file)       { File.join(@temp_folder, file_name) }
  let(:file_name)         { 'make-pretty.rb' }
  let(:content)           { "class David\ndef initialize(abc,xyz); @abc=abc; end\nend" }
  let(:setup_sample_file) { builder.add_file(file_name, content: content) } # File.write(target_file, content) }

  before :each do
    builder_module.configure(&cfg)
  end
  after :each do
    builder_module.reset
  end

  shared_context :temp_dir do
    include_context :use_temp_folder

    let(:cfg) do
      ->(config) { config.target_folders.add(:src, @temp_folder) }
    end
  end

  shared_examples :valid? do
    it { expect(instance.valid?).to be_truthy }
  end

  shared_examples :invalid? do
    it { expect(instance.valid?).to be_falsey }
  end

  describe '#initialize' do
    include_context :temp_dir

    context 'file_pattern param' do
      context 'is nil' do
        let(:file_pattern) { nil }
        it_behaves_like :invalid?
      end

      context 'is empty' do
        let(:file_pattern) { '' }
        it_behaves_like :invalid?
      end

      context 'does not match any files' do
        let(:file_pattern) { '*.rb' }
        it_behaves_like :invalid?
      end

      context 'matches existing files' do
        before { setup_sample_file }

        context 'and file_pattern is *.rb' do
          let(:file_pattern) { File.join(builder.target_folders.current_folder, '*.rb') }
          it_behaves_like :valid?
        end

        context 'and file_pattern is absolute filename' do
          let(:file_pattern) { target_file }
          it_behaves_like :valid?
        end
      end
    end

    context 'when valid sample file' do
      let(:file_pattern) { target_file }

      before { setup_sample_file }

      context '.fix_safe' do
        subject { instance.fix_safe }

        context 'is nil' do
          let(:opts) { { fix_safe: nil } }

          it { is_expected.to be_falsey }
          it_behaves_like :valid?
        end

        context 'is false' do
          let(:opts) { { fix_safe: false } }

          it { is_expected.to be_falsey }
          it_behaves_like :valid?
        end

        context 'is true' do
          let(:opts) { { fix_safe: true } }

          it { is_expected.to be_truthy }
          it_behaves_like :valid?
        end
      end

      context '.fix_unsafe' do
        subject { instance.fix_unsafe }

        context 'is nil' do
          let(:opts) { { fix_unsafe: nil } }

          it { is_expected.to be_falsey }
          it_behaves_like :valid?
        end

        context 'is false' do
          let(:opts) { { fix_unsafe: false } }

          it { is_expected.to be_falsey }
          it_behaves_like :valid?
        end

        context 'is true' do
          let(:opts) { { fix_unsafe: true } }

          it { is_expected.to be_truthy }
          it_behaves_like :valid?
        end
      end

      context '.rubo_config_file' do
        subject { instance.rubo_config_file }

        context 'is nil' do
          let(:opts) { { rubo_config_file: nil } }

          it { is_expected.to be_blank }
          it_behaves_like :valid?
        end

        context 'exists' do
          let(:opts) { { rubo_config_file: rubo_config_file } }

          it { is_expected.not_to be_blank }
          it_behaves_like :valid?
        end

        context 'not found' do
          let(:opts) { { rubo_config_file: 'some_unknown_file.yml' } }

          it { is_expected.not_to be_blank }
          it_behaves_like :invalid?
        end
      end

      # context '#debug' do
      #   let(:opts) { { fix_safe: true, fix_unsafe: true, rubo_config_file: rubo_config_file } }
      #   it { instance.debug }
      # end
    end
  end

  context 'content after execute' do
    include_context :temp_dir

    subject { File.read(target_file).strip }

    before { setup_sample_file }
    before { instance.execute }

    # fit { binding.pry }
    context 'when no settings provided' do
      context 'file remains unchanged' do
        it { is_expected.to eq(content) }
      end
    end

    context 'when :fix_safe, aka safe auto fix (-a) is provided' do
      let(:opts) { { fix_safe: true } }

      it {
        expected = <<~RUBY.strip
          class David
            def initialize(abc, _xyz)
              @abc = abc
            end
          end
        RUBY

        is_expected.to eq(expected)
      }
    end

    context 'when :fix_unsafe, aka unsafe auto fix (-A) is provided' do
      let(:opts) { { fix_unsafe: true } }

      it {
        expected = <<~RUBY.strip
          # frozen_string_literal: true

          class David
            def initialize(abc, _xyz)
              @abc = abc
            end
          end
        RUBY

        is_expected.to eq(expected)
      }
    end

    context 'when :fix_unsafe and custom rubo_config_file' do
      let(:opts) { { fix_unsafe: true, rubo_config_file: rubo_config_file } }

      it {
        expected = <<~RUBY.strip
          # frozen_string_literal: true

          class David
            def initialize(abc, xyz)
              @abc = abc
            end
          end
        RUBY

        puts subject

        is_expected.to eq(expected)
      }
    end

    context 'when :show_console' do
      let(:opts) { { show_console: true } }

      context 'file remains unchanged, but potential fixes are logged to console' do
        it { is_expected.to eq(content) }
      end
    end
  end
end
