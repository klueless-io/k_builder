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

  describe 'target_folder' do
    context 'with custom configuration' do
      it do
        data = KBuilder::Builder.build do |b|
          b.target_folder('xmen')
        end
        expect(data)
          .to  be_a(Hash) # Child class may return a DryStruct or OpenStruct
          .and include('target_folder' => 'xmen')
          .and include('template_folder' => builder_module.configuration.template_folder)
          .and include('template_folder_global' => builder_module.configuration.template_folder_global)
      end
    end
  end

  # describe 'target_folder=' do
  #   subject { described_class.target_folder('xyz') }
  #   context 'with default configuration' do
  #     it do
  #       subject
  #       is_expected
  #         .to  include('target_folder' => 'xyz')
  #     end
  #   end
  # end
end
