# frozen_string_literal: true

RSpec.describe KBuilder::NamedFolders do
  let(:instance) { described_class.new }
  let(:samples_folder) { File.join(Dir.getwd, 'spec', 'samples') }
  let(:target_folder) { File.join(samples_folder, 'target') }
  let(:target_documentation_folder) { File.join(samples_folder, 'target-documention') }
  let(:webpack_folder) { File.join(target_folder, 'config') }
  let(:slide_folder) { '~/slides' }

  describe '#initialize' do
    subject { instance }

    it { is_expected.not_to be_nil }

    describe '.folders' do
      subject { instance.folders }

      it { is_expected.to be_empty }
    end
  end

  describe '#add' do
      # instance.add(domain_template_folder)
      # instance.add(app_template_folder)

    describe '.folders' do
      subject { instance.folders }

      context ':app (or root) folder' do
        before { instance.add(:app, target_folder) }

        # May want to support :default or :root here
        it { is_expected.to include(app: target_folder)}

        context ':package folder is aliased to :app folder' do
          before { instance.add(:package, :app) }

          it do
            is_expected
              .to  include(app: target_folder)
              .and include(package: target_folder)
          end
        end
        context 'webpack folder is a sub-folder of :app' do
          before { instance.add(:webpack, instance.join(:app, 'config')) }

          it do
            is_expected
              .to  include(app: target_folder)
              .and include(webpack: webpack_folder)
          end
        end
        context 'slide folder uses tilda expansion' do
          before { instance.add(:slide, slide_folder) }

          it do
            is_expected
              .to  include(app: target_folder)
              .and include(slide: File.expand_path(slide_folder))
          end
        end
      end
    end

  #   folders = NamedFolders.new
  #   folders.add(:csharp       , '~/dev/csharp/cool-project')
  #   folders.add(:package_json , :csharp)
  #   folders.add(:webpack      , folders.join(:csharp, 'config'))
  #   folders.add(:builder      , folders.join(:csharp, 'builder'))
  #   folders.add(:slides       , '~/doc/csharp/cool-project')

    # context '.folders' do
    #   subject { instance.folders }

    #   it { is_expected.not_to be_empty }
    #   it { is_expected.to have_attributes(count: 4) }
    #   it do
    #     is_expected
    #       .to include(
    #         File.expand_path(tilda_folder),
    #         app_template_folder,
    #         domain_template_folder,
    #         global_template_folder
    #       )
    #   end
    # end
  end

  # Join for joining named folders to sub-folders
  describe '#join' do
    before { instance.add(:app, target_folder) }

    context 'join folder' do
      subject { instance.join(:app, 'config') }
      
      it { is_expected.to eq(File.join(target_folder, 'config')) }

      context 'join multiple subfolders' do
        subject { instance.join(:app, 'config', 'more') }
        
        it { is_expected.to eq(File.join(target_folder, 'config', 'more')) }
      end
    end
  end

  # Get_filename for joining named folders to sub-folders + file (alias to #join)
  describe '#get_filename' do
    before { instance.add(:app, target_folder) }
    context 'get_filename folder' do
      subject { instance.get_filename(:app, 'output.txt') }
      
      it { is_expected.to eq(File.join(target_folder, 'output.txt')) }

      context 'get_filename multiple subfolders' do
        subject { instance.get_filename(:app, 'config', 'output.txt') }
        
        it { is_expected.to eq(File.join(target_folder, 'config', 'output.txt')) }
      end
    end
  end

  describe '#get' do
    before { instance.add(:app, target_folder) }

    context 'get registered folder' do
      subject { instance.get(:app) }
      
      it { is_expected.to eq(target_folder) }
    end

    context 'get unknown folder' do
      subject { instance.get(:xxx) }
      
      it { expect { subject }.to raise_error(KBuilder::Error, "Folder not found, this folder key not found: xxx") }
    end
  end
end
