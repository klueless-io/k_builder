# frozen_string_literal: true

RSpec.describe KBuilder::Commands::CodeSyntaxHighlighterCommand do
  # Command setup
  let(:instance)          { described_class.new(source_code, **opts) }
  let(:opts)              { {} }

  # Builder setup (dependency)
  let(:builder)           { KBuilder::BaseBuilder.init }
  let(:builder_module)    { KBuilder }
  let(:cfg)               { ->(config) {} }

  # Input parameter (dependencies)
  let(:source_code)       { "class David\ndef initialize(abc,xyz); @abc=abc; end\nend" }

  before :each do
    builder_module.configure(&cfg)
  end
  after :each do
    builder_module.reset
  end

  # shared_context :temp_dir do
  #   include_context :use_temp_folder

  #   let(:cfg) do
  #     ->(config) { config.target_folders.add(:src, @temp_folder) }
  #   end
  # end

  shared_examples :valid? do
    it { expect(instance.valid?).to be_truthy }
  end

  shared_examples :invalid? do
    it { expect(instance.valid?).to be_falsey }
  end

  describe '#initialize' do
    # include_context :temp_dir

    context 'source_code param' do
      context 'is nil' do
        let(:source_code) { nil }
        it_behaves_like :invalid?
      end

      context 'is empty' do
        let(:source_code) { '' }
        it_behaves_like :invalid?
      end

      context 'exists' do
        it_behaves_like :valid?
      end
    end
  end

  # NOT WORKING?
  # describe '#execute' do
  #   context 'on execute' do
  #     before { instance.execute }

  #     context 'when content is valid' do
  #       context '.formatted_code' do
  #         subject { instance.formatted_code }

  #         it { is_expected.to eq(%w[red yellow blue]) }
  #       end
  #     end
  #   end
  # end
end
