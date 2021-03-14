# frozen_string_literal: true

# Usecases do not follow Rspec guidelines,
# They instead follow Rspec::Usecase guidelines
RSpec.describe 'Usecases::BuilderUsingConfiguration' do
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

  describe 'builder' do
    it 'write a template' do
      template = <<~TEXT
        Configured Template Folder        : {{a}}
        Configured Global Template Folder : {{b}}
        Configured Output Folder          : {{c}}
      TEXT

      builder = KBuilder::Builder.init

      builder
        .add_file('main.rb', template_file: 'class.rb', name: 'main')
        .add_file('person.rb',
                  template_file: 'model.rb',
                  name: 'person',
                  fields: %i[first_name last_name])
        .add_file('address.rb',
                  template_file: 'model.rb',
                  name: 'address',
                  fields: %i[street1 street2 post_code state])
        .add_file('configuration.log.txt',
                  template: template,
                  a: builder.template_folder,
                  b: builder.global_template_folder,
                  c: builder.target_folder)
        .add_file('css/index.css', template_file: 'class.rb', colors: 'main')
    end
  end
end
