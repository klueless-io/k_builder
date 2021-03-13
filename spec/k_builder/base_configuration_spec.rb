# frozen_string_literal: true

# Sample class for this test
class ComplexChild < KBuilder::BaseConfiguration
  attr_accessor :aaa, :bbb

  def initialize(aaa)
    super()
    @aaa = aaa
  end
end

RSpec.describe KBuilder::BaseConfiguration do
  let(:instance) { described_class.new }

  describe '#as_hash' do
    subject { instance.to_hash }

    it { is_expected.to eq({}) }

    context 'with instance_variable' do
      before { instance.instance_variable_set('@test', 'test value') }

      it { is_expected.to eq({ 'test' => 'test value' }) }
    end
  end

  context 'meta programming' do
    context 'simple key/values' do
      describe '.key' do
        subject { instance.key }

        context 'when no key' do
          it { expect(subject).to be_nil }
        end

        describe '#key=' do
          before { instance.key = 'set via setter' }

          it { expect(subject).to eq('set via setter') }
        end

        describe '#key(value)' do
          before { instance.key('set via method') }

          it { expect(subject).to eq('set via method') }
        end
      end
    end

    context 'complex child configuration' do
      before do
        instance.some_child = ComplexChild.new('aa')
        instance.some_child.ccc = 'cc'
      end

      subject { instance.some_child }

      it { is_expected.not_to be_nil }

      context 'existing attribute initialized via constructor' do
        subject { instance.some_child.aaa }

        it { is_expected.to eq('aa') }
      end

      context 'existing attribute not initialized in constructor' do
        subject { instance.some_child.bbb }

        it { is_expected.to be_nil }
      end

      context 'unknown attribute set via setter' do
        subject { instance.some_child.ccc }

        it { is_expected.to eq('cc') }
      end

      context 'unknown attribute not set' do
        subject { instance.some_child.ddd }

        it { is_expected.to be_nil }
      end
    end
  end
end
