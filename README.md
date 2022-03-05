# K Builder

> KBuilder provides various fluent builders and code generators for initializing applications with different language requirements

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'k_builder'
```

And then execute:

```bash
bundle install
```

Or install it yourself as:

```bash
gem install k_builder
```

## Stories

### Main Story

As a Polyglot Developer, I want to be up and running in any development language with consistency, so I am productive and using best practices

See all [stories](./STORIES.md)

## Usage

See all [usage examples](./USAGE.md)

### Basic Example

#### Configure and Run

Setup configuration for KBuilder

Generate two files:

1. main.rb is based on class.rb from app_template
2. configuration.log.txt is based on an inline template

Check out usage.md for more details

```ruby
usecases_folder = File.join(Dir.getwd, 'spec', 'usecases')

KConfig.configure do |config|
  config.template_folder = File.join(usecases_folder, '.app_template')
  config.global_template_folder = File.join(usecases_folder, '.global_template')
  config.target_folder = File.join(usecases_folder, '.output')
end

template = <<~TEXT
  Configured Template Folder        : {{a}}
  Configured Global Template Folder : {{b}}
  Configured Output Folder          : {{c}}
TEXT

builder = KBuilder::Builder.init

builder.add_file('main.rb', template_file: 'class.rb', name: 'main').add_file(
  'configuration.log.txt',
  template: template,
  a: builder.template_folder,
  b: builder.global_template_folder,
  c: builder.target_folder
)
```

## Development

Checkout the repo

```bash
git clone klueless-io/k_builder
```

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests.

You can also run `bin/console` for an interactive prompt that will allow you to experiment.

```bash
bin/console

Aaa::Bbb::Program.execute()
# => ""
```

`k_builder` is setup with Guard, run `guard`, this will watch development file changes and run tests automatically, if successful, it will then run rubocop for style quality.

To release a new version, update the version number in `version.rb`, build the gem and push the `.gem` file to [rubygems.org](https://rubygems.org).

```bash
gem build
gem push rspec-usecases-?.?.??.gem
# or push the latest gem
ls *.gem | sort -r | head -1 | xargs gem push
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/klueless-io/k_builder. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the K Builder project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/klueless-io/k_builder/blob/master/CODE_OF_CONDUCT.md).

## Copyright

Copyright (c) David Cruwys. See [MIT License](LICENSE.txt) for further details.
