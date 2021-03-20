# frozen_string_literal: true

# Usecases do not follow Rspec guidelines,
# They instead follow Rspec::Usecase guidelines
RSpec.describe 'Usecases::Configuration' do
  before :each do
    usecases_folder = File.join(Dir.getwd, 'spec', 'usecases')

    KBuilder.configure do |config|
      config.target_folders.add(:app, File.join(usecases_folder, '.output'))

      config.template_folders.add(:global , File.join(usecases_folder, '.global_template'))
      config.template_folders.add(:app , File.join(usecases_folder, '.app_template'))
    end
  end

  after :each do
    KBuilder.reset
  end

  describe 'print configuration' do
    subject { KBuilder.configuration.to_h }

    it do
      puts JSON.pretty_generate(subject)
    end
  end
end
