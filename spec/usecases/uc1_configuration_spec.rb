# frozen_string_literal: true

# Usecases do not follow Rspec guidelines,
# They instead follow Rspec::Usecase guidelines
RSpec.describe 'Usecases::Configuration' do
  before :each do
    usecases_folder = File.join(Dir.getwd, 'spec', 'usecases')

    KBuilder.configure do |config|
      config.template_folder = File.join(usecases_folder, '.app_template')
      config.global_template_folder = File.join(usecases_folder, '.global_template')
      config.target_folder = File.join(usecases_folder, '.output')
    end
  end
  after :each do
    KBuilder.reset
  end

  describe 'print configuration' do
    subject { KBuilder.configuration.to_hash }

    it do
      puts JSON.pretty_generate(subject)
    end
  end
end
