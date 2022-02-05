# frozen_string_literal: true

# Usecases do not follow Rspec guidelines,
# They instead follow Rspec::Usecase guidelines
RSpec.describe 'Usecases::BuilderUsingConfiguration' do
  before :each do
    usecases_folder = File.join(Dir.getwd, 'spec', 'usecases')

    KConfig.configure do |config|
      config.target_folders.add(:app, File.join(usecases_folder, '.output'))

      config.template_folders.add(:global , File.join(usecases_folder, '.global_template'))
      config.template_folders.add(:app , File.join(usecases_folder, '.app_template'))
    end
  end

  after :each do
    KConfig.reset
  end

  describe 'builder' do
    it 'write a template' do
      template = <<~TEXT
        Configured Template Folder        : {{a}}
        Configured Global Template Folder : {{b}}
        Configured Output Folder          : {{c}}
      TEXT

      builder = KBuilder::BaseBuilder.init

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
                  a: builder.get_template_folder(:app),
                  b: builder.get_template_folder(:global),
                  c: builder.target_folder)
        .add_file('css/index.css',
                  template: '{{#each colors}} .{{.}} { color: {{.}} }  {{/each}}',
                  colors: %w[red blue green],
                  pretty: true)
    end
  end
end
