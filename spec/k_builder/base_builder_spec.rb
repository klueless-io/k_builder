# frozen_string_literal: true

RSpec.describe KBuilder::BaseBuilder do
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

    it { expect { subject }.to raise_error NotImplementedError }
  end

  describe '#init' do
    subject { described_class.init }

    it { expect { subject }.to raise_error NotImplementedError }
  end

  describe '#build' do
    subject { described_class.build }

    it { expect { subject }.to raise_error NotImplementedError }
  end
end
