# frozen_string_literal: true

RSpec.describe KBuilder do
  it 'has a version number' do
    expect(KBuilder::VERSION).not_to be nil
  end

  it 'has a standard error' do
    expect { raise KBuilder::Error, 'some message' }
      .to raise_error('some message')
  end
end
