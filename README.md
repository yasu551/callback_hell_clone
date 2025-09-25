# Callback Hell Clone

Callback Hell is a Ruby gem that analyzes your Ruby on Rails application models and provides actionable insights on callbacks and validations. Use it to identify models that might benefit from refactoring, spot callback pollution from gems and associations, and keep your models clean and maintainable.

## Features

- 🔍 **Model Analysis**: Automatically detect callbacks and validations in your Rails models
- 🚨 **Pollution Detection**: Identify callback pollution from gems and associations
- 📊 **Detailed Reports**: Get actionable insights with colorized output
- 🎯 **Focused Recommendations**: Receive specific suggestions for model refactoring
- 📈 **Multiple Formats**: Support for text, JSON, and CSV output formats

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'callback_hell_clone'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install callback_hell_clone

## Usage

### Command Line Interface

Analyze your Rails application models:

```bash
# Analyze models in current directory
callback_hell

# Analyze models in specific path
callback_hell analyze /path/to/your/rails/app

# Verbose output with detailed information
callback_hell analyze --verbose

# JSON output format
callback_hell analyze --format json

# CSV output format
callback_hell analyze --format csv

# Disable colored output
callback_hell analyze --no-color
```

### Ruby API

```ruby
require 'callback_hell'

# Basic analysis
analysis = CallbackHell.analyze("path/to/rails/app")

# Generate report with options
CallbackHell.report("path/to/rails/app", {
  verbose: true,
  format: :json,
  color: true
})
```

## What It Detects

### Callbacks
- `before_validation`, `after_validation`
- `before_save`, `after_save`, `around_save`
- `before_create`, `after_create`, `around_create`
- `before_update`, `after_update`, `around_update`
- `before_destroy`, `after_destroy`, `around_destroy`
- `after_commit`, `after_rollback`
- `after_initialize`, `after_find`
- `before_touch`, `after_touch`

### Validations
- `validates`, `validates_presence_of`, `validates_absence_of`
- `validates_acceptance_of`, `validates_confirmation_of`
- `validates_format_of`, `validates_inclusion_of`, `validates_exclusion_of`
- `validates_length_of`, `validates_numericality_of`, `validates_uniqueness_of`
- `validates_with`, `validates_each`, `validate`

### Pollution Sources
- Gem-added callbacks (acts_as_paranoid, paperclip, carrierwave, aasm, friendly_id, etc.)
- Association callbacks (dependent: :destroy, :delete_all, :nullify)
- Heavy callback/validation usage patterns

## Thresholds

- **Callback-heavy models**: 5 or more callbacks
- **Validation-heavy models**: 8 or more validations
- **Potentially polluted**: Models with gem pollution indicators or association callback pollution

## Example Output

```
🔥 CALLBACK HELL ANALYSIS REPORT 🔥

==================================================
SUMMARY
==================================================
Total models analyzed: 12
Models with callbacks: 8
Models with validations: 10
Callback-heavy models: 2
Validation-heavy models: 1
Potentially polluted models: 3

CALLBACK ANALYSIS
--------------------
⚠️  CALLBACK-HEAVY MODELS (≥5 callbacks):
  • User: 7 callbacks
  • Order: 5 callbacks

VALIDATION ANALYSIS
--------------------
⚠️  VALIDATION-HEAVY MODELS (≥8 validations):
  • Product: 9 validations

POLLUTION ANALYSIS
--------------------
🚨 POTENTIALLY POLLUTED MODELS:
  • User
  • Document
  • BlogPost

RECOMMENDATIONS
--------------------
📋 For callback-heavy models:
   - Consider extracting callback logic into service objects
   - Use observers for cross-cutting concerns
   - Break down complex callbacks into smaller, focused methods
📋 For validation-heavy models:
   - Group related validations together
   - Consider custom validation methods for complex logic
   - Use form objects for context-specific validations
📋 For polluted models:
   - Review gem-added callbacks and validations
   - Consider if all functionality is needed
   - Move non-essential concerns to decorators or service layers
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/yasu551/callback_hell_clone.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).