# frozen_string_literal: true

RSpec.describe KBuilder::ConfigurationExtension do
  let(:k_config) { KConfig }
  let(:cfg) { ->(config) {} }
  let(:instance) { k_config.configuration }

  let(:custom_target_folder1) { '~/my-target-folder1' }
  let(:custom_target_folder2) { '~/my-target-folder2' }

  let(:expected_target_folder1) { File.expand_path(custom_target_folder1) }
  let(:expected_target_folder2) { File.expand_path(custom_target_folder2) }

  let(:custom_template_folder) { '~/my-template-folder' }
  let(:custom_domain_template_folder) { '~/my-template-folder-domain' }
  let(:custom_global_template_folder) { '~/my-template-folder-global' }

  let(:expected_template_folder) { File.expand_path(custom_template_folder) }
  let(:expected_domain_template_folder) { File.expand_path(custom_domain_template_folder) }
  let(:expected_global_template_folder) { File.expand_path(custom_global_template_folder) }

  shared_context 'target configuration' do
    let(:cfg) do
      lambda { |config|
        config.target_folders.add(:src, custom_target_folder1)
        config.target_folders.add(:dst, custom_target_folder2)
      }
    end
  end

  shared_context 'template configuration' do
    let(:cfg) do
      lambda { |config|
        config.template_folders.add(:global , custom_global_template_folder)
        config.template_folders.add(:domain , custom_domain_template_folder)
        config.template_folders.add(:app    , custom_template_folder)
      }
    end
  end

  shared_context 'target + template configuration' do
    let(:cfg) do
      lambda { |config|
        config.target_folders.add(:src, custom_target_folder1)
        config.target_folders.add(:dst, custom_target_folder2)

        config.template_folders.add(:global , custom_global_template_folder)
        config.template_folders.add(:domain , custom_domain_template_folder)
        config.template_folders.add(:app    , custom_template_folder)
      }
    end
  end

  describe 'when using default configuration' do
    before :each do
      k_config.configure(&cfg)
    end
    after :each do
      k_config.reset
    end

    context 'debug' do
      include_context 'target + template configuration'

      it { k_config.configuration.debug(:k_builder_debug) }
    end

    describe '.target_folders' do
      subject { instance.target_folders.folders }

      context 'when not configured' do
        it { is_expected.to be_empty }
      end

      context 'when configured' do
        include_context 'target configuration'

        it do
          is_expected
            .to  include(src: expected_target_folder1)
            .and include(dst: expected_target_folder2)
        end
      end
    end

    describe '.template_folders' do
      subject { instance.template_folders }

      context 'when not configured' do
        it { is_expected.not_to be_nil }

        context '.ordered_keys' do
          subject { instance.template_folders.ordered_keys }

          it { is_expected.to be_empty }
        end

        context '.ordered_folders' do
          subject { instance.template_folders.ordered_folders }

          it { is_expected.to be_empty }
        end

        context '.folders' do
          subject { instance.template_folders.folders }

          it { is_expected.to be_empty }
        end
      end

      context 'when configured' do
        include_context 'template configuration'

        subject { instance.template_folders.ordered_folders }

        context '.ordered_keys' do
          subject { instance.template_folders.ordered_keys }

          it { is_expected.to eq(%i[app domain global]) }
        end

        context '.ordered_folders' do
          subject { instance.template_folders.ordered_folders }

          it { is_expected.to eq([expected_template_folder, expected_domain_template_folder, expected_global_template_folder]) }
        end

        context '.folders' do
          subject { instance.template_folders.folders }

          it do
            is_expected
              .to  include(global: expected_global_template_folder)
              .and include(domain: expected_domain_template_folder)
              .and include(app: expected_template_folder)

            # [expected_template_folder, expected_domain_template_folder, expected_global_template_folder]
          end
        end
      end
    end

    describe '#clone' do
      let(:copy) { instance.clone }

      include_context 'target + template configuration'

      before do
        copy.target_folders.add(:custom, '/custom')
        copy.template_folders.add(:more, '/more')
      end

      context 'original' do
        let(:target) { instance }

        context '.target_folders' do
          context '.count' do
            subject { target.target_folders.folders.count }

            it { is_expected.to eq(2) }
          end

          context '.folders' do
            subject { target.target_folders.folders }

            it { is_expected.to have_key(:src).and have_key(:dst) }
            it { is_expected.not_to have_key(:custom) }
          end
        end

        context '.template_folders' do
          context '.count' do
            subject { target.template_folders.folders.count }

            it { is_expected.to eq(3) }
          end

          context '.folders' do
            subject { target.template_folders.folders }

            it { is_expected.to have_key(:global).and have_key(:domain).and have_key(:app) }
            it { is_expected.not_to have_key(:more) }
          end

          context '.ordered_keys' do
            subject { target.template_folders.ordered_keys }

            it { is_expected.to eq(%i[app domain global]) }
          end

          context '.ordered_folders' do
            subject { target.template_folders.ordered_folders }

            it do
              is_expected
                .to  include(expected_template_folder)
                .and include(expected_domain_template_folder)
                .and include(expected_global_template_folder)
            end
          end
        end
      end

      context 'copy' do
        let(:target) { copy }

        context '.target_folders' do
          context '.count' do
            subject { target.target_folders.folders.count }

            it { is_expected.to eq(3) }
          end

          context '.folders' do
            subject { target.target_folders.folders }

            it { is_expected.to have_key(:src).and have_key(:dst).and have_key(:custom) }
          end
        end

        context '.template_folders' do
          context '.count' do
            subject { target.template_folders.folders.count }

            it { is_expected.to eq(4) }
          end

          context '.folders' do
            subject { target.template_folders.folders }

            it { is_expected.to have_key(:global).and have_key(:domain).and have_key(:app).and have_key(:more) }
          end

          context '.ordered_keys' do
            subject { target.template_folders.ordered_keys }

            it { is_expected.to eq(%i[more app domain global]) }
          end

          context '.ordered_folders' do
            subject { target.template_folders.ordered_folders }

            it do
              is_expected
                .to  include('/more')
                .and include(expected_template_folder)
                .and include(expected_domain_template_folder)
                .and include(expected_global_template_folder)
            end
          end
        end
      end
    end

    describe '#to_h' do
      subject { instance.to_h }

      let(:cfg) do
        lambda { |config|
          config.target_folders.add(:src, custom_target_folder1)
          config.target_folders.add(:dst, custom_target_folder2)

          config.template_folders.add(:global , custom_global_template_folder)
          config.template_folders.add(:domain , custom_domain_template_folder)
          config.template_folders.add(:app    , custom_template_folder)
        }
      end

      it do
        is_expected
          .to be_a(Hash)
          .and have_key('target_folders')
          .and  include('target_folders' => include(:src))
          .and  include('target_folders' => include(:dst))
          .and have_key('target_folders')
          .and have_key('template_folders')
          .and  include('template_folders' => include(:ordered))
          .and  include('template_folders' => include(:global))
          .and  include('template_folders' => include(:domain))
          .and  include('template_folders' => include(:app))
      end
    end
  end

  describe 'when using configuration channels' do
    # before :each do
    #   k_config.configure(&cfg)
    # end
    # after :each do
    #   k_config.reset
    # end

    context 'when two channels' do
      let(:instance) { k_config.configuration(channel) }

      before do
        k_config.reset(:microapp)
        k_config.reset(:data)

        k_config.configure(:microapp) do |config|
          config.template_folders.add(:microapp, '~/dev/definitions/microapp')
          config.target_folders.add(:root, '~/dev/some_app')
        end

        k_config.configure(:data) do |config|
          config.target_folders.add(:root, '~/dev/some_data')
        end
      end

      context 'when microapp configuration channel' do
        let(:channel) { :microapp }

        context '.target_folders.get(:root)' do
          subject { instance.target_folders.get(:root) }

          it { is_expected.to eq(File.expand_path('~/dev/some_app')) }
        end

        context '.template_folders.get(:microapp)' do
          subject { instance.template_folders.get(:microapp) }

          it { is_expected.to eq(File.expand_path('~/dev/definitions/microapp')) }
        end
      end

      context 'for data configuration' do
        let(:channel) { :data }

        context '.target_folders.get(:root)' do
          subject { instance.target_folders.get(:root) }

          it { is_expected.to eq(File.expand_path('~/dev/some_data')) }
        end

        context '.template_folders.get(:microapp)' do
          subject { instance.template_folders.folders }

          it { is_expected.to be_empty }
        end
      end
    end
  end
end
