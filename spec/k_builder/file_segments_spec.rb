# frozen_string_literal: true

RSpec.describe KBuilder::FileSegments do
  subject { instance }

  let(:instance) { described_class.new(file) }
  let(:file) { '/a/b/c/d.txt' }

  context '.file' do
    subject { instance.file }

    it { is_expected.to eq('/a/b/c/d.txt') }
  end

  context '.path' do
    subject { instance.path }

    it { is_expected.to eq('/a/b/c') }
  end

  context '.file_name' do
    subject { instance.file_name }

    it { is_expected.to eq('d.txt') }
  end

  context '.ext' do
    subject { instance.ext }

    it { is_expected.to eq('.txt') }
  end

  context '.file_name_only' do
    subject { instance.file_name_only }

    it { is_expected.to eq('d') }
  end

  describe '#interplate' do
    subject { instance.interpolate(target_file) }

    context '$T_FILE$' do
      let(:target_file) { '$T_FILE$' }
      it { is_expected.to eq('/a/b/c/d.txt') }
    end

    context '$T_PATH$' do
      let(:target_file) { '$T_PATH$' }

      it { is_expected.to eq('/a/b/c') }
    end

    context '$T_FILE_NAME$' do
      let(:target_file) { '$T_FILE_NAME$' }

      it { is_expected.to eq('d.txt') }
    end

    context '$T_EXT$' do
      let(:target_file) { '$T_EXT$' }

      it { is_expected.to eq('.txt') }
    end

    context '$T_FILE_NAME_ONLY$' do
      let(:target_file) { '$T_FILE_NAME_ONLY$' }

      it { is_expected.to eq('d') }
    end

    context 'Combination' do
      context '$T_PATH$/$T_FILE_NAME_ONLY$$T_EXT$'
      let(:target_file) { '$T_PATH$/$T_FILE_NAME_ONLY$$T_EXT$' }

      it { is_expected.to eq('/a/b/c/d.txt') }
    end
  end
end
