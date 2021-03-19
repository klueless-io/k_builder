# frozen_string_literal: true

RSpec.describe KBuilder::LayeredFolders do
  let(:instance) { described_class.new }
  let(:samples_folder) { File.join(Dir.getwd, 'spec', 'samples') }
  let(:fallback_folder) { '~/x' }
  let(:expected_fallback_folder) { File.expand_path(fallback_folder) }
  let(:app_template_folder) { File.join(samples_folder, 'app-template') }
  let(:domain_template_folder) { File.join(samples_folder, 'domain-template') }
  let(:global_template_folder) { File.join(samples_folder, 'global-template') }
  let(:global_template_shim_folder) { File.join(samples_folder, 'global-shim-template') }

  describe '#initialize' do
    subject { instance }

    it { is_expected.not_to be_nil }

    context '.folders' do
      subject { instance.folders }

      it { is_expected.to be_empty }
    end

    describe '.ordered_folders' do
      subject { instance.ordered_folders }

      it { is_expected.to be_empty }
    end
  end

  describe '#add' do
    before do
      instance.add(:fallback  , fallback_folder)
      instance.add(:global    , global_template_folder)
      instance.add(:domain    , domain_template_folder)
      instance.add(:app       , app_template_folder)
    end

    context '.ordered_folders' do
      subject { instance.ordered_folders }

      it { is_expected.not_to be_empty }
      it { is_expected.to have_attributes(count: 4) }
      it do
        is_expected
          .to include(
            app_template_folder,
            domain_template_folder,
            global_template_folder,
            expected_fallback_folder
          )
      end
    end

    context '.ordered_keys' do
      subject { instance.ordered_keys }

      it { is_expected.not_to be_empty }
      it { is_expected.to have_attributes(count: 4) }
      it { is_expected.to eq(%i[app domain global fallback]) }
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

    describe '#clone' do
      let(:copy) { instance.clone }

      before do
        copy.add(:custom, '/custom')
      end

      context 'original' do
        let(:target) { instance }

        context '.count' do
          subject { target.folders.count }

          it { is_expected.to eq(4) }
        end

        context '.folders' do
          subject { target.folders }

          it { is_expected.to have_key(:app).and have_key(:domain).and have_key(:global).and have_key(:fallback) }
          it { is_expected.not_to have_key(:custom) }
        end

        context '.ordered_keys' do
          subject { target.ordered_keys }

          it { is_expected.to eq(%i[app domain global fallback]) }
        end

        context '.ordered_folders' do
          subject { target.ordered_folders }

          it do
            is_expected
              .to  include(app_template_folder)
              .and include(domain_template_folder)
              .and include(global_template_folder)
              .and include(expected_fallback_folder)
          end
        end
      end

      context 'copy' do
        let(:target) { copy }

        context '.count' do
          subject { target.folders.count }

          it { is_expected.to eq(5) }
        end

        context '.folders' do
          subject { target.folders }

          it { is_expected.to have_key(:app).and have_key(:domain).and have_key(:global).and have_key(:fallback).and have_key(:custom) }
        end

        context '.ordered_keys' do
          subject { target.ordered_keys }

          it { is_expected.to eq(%i[custom app domain global fallback]) }
        end

        context '.ordered_folders' do
          subject { target.ordered_folders }

          it do
            is_expected
              .to  include('/custom')
              .and include(app_template_folder)
              .and include(domain_template_folder)
              .and include(global_template_folder)
              .and include(expected_fallback_folder)
          end
        end
      end
    end

    describe '#to_h' do
      subject { instance.to_h }

      context 'add some folders' do
        it do
          is_expected
            .to  include(ordered: include(keys: instance.ordered_keys))
            .and include(ordered: include(folders: instance.ordered_folders))
            .and include(instance.folders)
        end
      end
    end
  end
end
