# K Builder

> KBuilder provides various fluent builders and code generators for initializing applications with different language requirements

As a Polyglot Developer, I want to be up and running in any development language with consistency, so I am productive and using best practices

## Development radar

### Stories next on list

As a Polyglot Developer, I want to be up and running in any development language with consistency, so I am productive and using best practices [EPIC]

As a Developer, I need builders to be easier to use, so I am more efficient

- Logging needs to be more informative
- Template errors need to log the template and the filename
- add_file with template_file: needs to support optional filename that is the same as the template_file (or use a token, eg. $TF_PATH$, $TF_NAME$, $TF_FILE$
- add_file, the files being generated are not being logged

## Stories and tasks

### Stories - completed

As a Developer, I want have multiple template, so I can group my templates by area of specialty

- Refactor global and app templates to a layered folder array using (First In, Last Out) priority
- Support subfolders of any template folder (maybe)

As a Developer, I want have multiple output folders, so I can write to multiple locations

- Refactor output folder so that there are multiple named output folders, with :default working the same way as the existing system
- Support subfolders of any output folder
- Support output folder change of focus

### Tasks - completed

WatchBuilder - Build Watcher (as a builder) - [k_builder-watch](https://github.com/klueless-io/k_builder-watch)

Refactor BaseBuilder

Setup RubyGems and RubyDoc

- Build and deploy gem to [rubygems.org](https://rubygems.org/gems/k_builder)
- Attach documentation to [rubydoc.info](https://rubydoc.info/github/to-do-/k_builder/master)

Setup project management, requirement and SCRUM documents

- Setup readme file
- Setup user stories and tasks
- Setup a project backlog
- Setup an examples/usage document

Setup GitHub Action (test and lint)

- Setup Rspec action
- Setup RuboCop action

Setup new Ruby GEM

- Build out a standard GEM structure
- Add automated semantic versioning
- Add Rspec unit testing framework
- Add RuboCop linting
- Add Guard for automatic watch and test
- Add GitFlow support
- Add GitHub Repository
