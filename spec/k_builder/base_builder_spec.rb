# frozen_string_literal: true

RSpec.describe KBuilder::BaseBuilder do
  let(:instance) { described_class.new }
  let(:builder_module) { KBuilder }
  let(:cfg) { ->(config) {} }

  before :each do
    builder_module.configure(&cfg)
  end
  after :each do
    builder_module.reset
  end

  describe '#initialize' do
    subject { instance }

    it { is_expected.not_to be_nil }

    context '.configuration' do
      subject { instance.configuration }

      it { is_expected.not_to be_nil }
    end
  end
  # it { expect { subject }.to raise_error NotImplementedError }

  describe '#init' do
    subject { described_class.init }

    it { is_expected.not_to be_nil }
  end

  describe '#build' do
    subject { described_class.build }

    it { expect { subject }.to raise_error NotImplementedError }
  end
end
