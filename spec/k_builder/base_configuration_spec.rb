# frozen_string_literal: true

# Sample class for this test
class ComplexChild < KBuilder::BaseConfiguration
  attr_accessor :aaa, :bbb

  def initialize(aaa)
    super()
    @aaa = aaa
  end
end

module KBuilder
  module ThirdParty
    class Configuration < BaseConfiguration
      attach_to(self, KBuilder::BaseConfiguration, :third_party)

      attr_accessor :aaa
      attr_accessor :bbb
      attr_accessor :ccc

      def initialize
        super()
        @aaa = '1'
        @bbb = '2'
        @ccc = '3'
      end
    end
  end
end

RSpec.describe KBuilder::BaseConfiguration do
  let(:instance) { described_class.new }

  describe '#to_h' do
    subject { instance.to_h }

    it { is_expected.to eq({}) }

    context 'with instance_variable' do
      before { instance.instance_variable_set('@test', 'test value') }

      it { is_expected.to eq({ 'test' => 'test value' }) }
    end
  end

  context 'extend configuration via third parties' do
    describe '#to_h' do
      subject { instance.to_h }

      it { is_expected.to eq({}) }
    end

    describe '#attach_to' do
      context 'when attachment is not configured' do
        it { is_expected.not_to respond_to(:some_new_config) }
      end
      context 'when attachment configured' do
        it { is_expected.to respond_to(:third_party) }

        describe '#to_h' do
          subject { instance.to_h }

          it { is_expected.to eq({}) }

          context 'after accessing third_party' do
            before { instance.third_party }

            it { is_expected.to eq('third_party' => { 'aaa' => '1', 'bbb' => '2', 'ccc' => '3' }) }
          end
        end
      end
    end
  end
end
