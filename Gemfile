# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

group :development, :test do
  gem 'guard-bundler'
  gem 'guard-rspec'
  gem 'guard-rubocop'
  gem 'rake' # , '~> 12.0'
  gem 'rake-compiler', require: false
  gem 'rspec', '~> 3.0'
  gem 'rubocop'
  gem 'rubocop-rake', require: false
  gem 'rubocop-rspec', require: false
end

if ENV['KLUE_LOCAL_GEMS']&.to_s&.downcase == 'true'
  group :development, :test do
    puts 'Using Local GEMs'
    gem 'handlebarsjs' , path: '../handlebarsjs'
  end
end
