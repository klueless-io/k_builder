# frozen_string_literal: true

RSpec.describe KBuilder::LayeredFolders do
  let(:instance) { described_class.new }
  let(:samples_folder) { File.join(Dir.getwd, 'spec', 'samples') }
  let(:app_template_folder) { File.join(samples_folder, 'app-template') }
  let(:domain_template_folder) { File.join(samples_folder, 'domain-template') }
  let(:global_template_folder) { File.join(samples_folder, 'global-template') }

  describe '#initialize' do
    subject { instance }

    it { is_expected.not_to be_nil }

    context '.folders' do
      subject { instance.folders }

      it { is_expected.to be_empty }
    end
  end

  describe '#add' do
    before do
      instance.add(global_template_folder)
      instance.add(domain_template_folder)
      instance.add(app_template_folder)
    end

    context '.folders' do
      subject { instance.folders }

      it { is_expected.not_to be_empty }
      it { is_expected.to have_attributes(count: 3) }
    end

    describe '#find_file_folder' do
      subject { instance.find_file_folder(file_parts) }

      context 'bad file' do
        let(:file_parts) { 'bad.txt' }

        it { is_expected.to be_nil }
      end

      context 'file in app and global folders' do
        let(:file_parts) { 'template1.txt' }

        it { is_expected.to end_with('app-template') }
      end

      context 'file in domain and global folders' do
        let(:file_parts) { 'template2.txt' }

        it { is_expected.to end_with('domain-template') }
      end

      context 'file in global folder only' do
        let(:file_parts) { 'template3.txt' }

        it { is_expected.to end_with('global-template') }
      end

      context 'sub-path file' do
        let(:file_parts) { ['abc', 'xyz', 'deep-template.txt'] }

        it { is_expected.to end_with('global-template') }
      end
    end

    describe '#find_file' do
      subject { instance.find_file(file_parts) }

      context 'bad file' do
        let(:file_parts) { 'bad.txt' }

        it { is_expected.to be_nil }
      end

      context 'file in app and global folders' do
        let(:file_parts) { 'template1.txt' }

        it { is_expected.to end_with('app-template/template1.txt') }
      end

      context 'file in domain and global folders' do
        let(:file_parts) { 'template2.txt' }

        it { is_expected.to end_with('domain-template/template2.txt') }
      end

      context 'file in global folder only' do
        let(:file_parts) { 'template3.txt' }

        it { is_expected.to end_with('global-template/template3.txt') }
      end

      context 'sub-path file' do
        let(:file_parts) { ['abc', 'xyz', 'deep-template.txt'] }

        it { is_expected.to end_with('global-template/abc/xyz/deep-template.txt') }
      end
    end
  end
end