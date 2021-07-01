# frozen_string_literal: true

RSpec.describe KBuilder::Commands::BaseCommand do
  let(:instance) { described_class.new(**opts) }
  let(:builder) { KBuilder::BaseBuilder.init }
  let(:opts) { {} }

  describe '#initialize' do
    context 'when no options' do
      subject { instance }

      it { is_expected.not_to be_nil }

      context '.valid?' do
        subject { instance.valid? }

        it { is_expected.to be_truthy }
      end

      context '.debug' do
        it { instance.debug(title: 'debug base command') }
      end
    end
  end

  context 'after guard' do
    before { instance.guard('some error') }

    context '.valid?' do
      subject { instance.valid? }

      it { is_expected.to be_falsey }
    end
  end
end
