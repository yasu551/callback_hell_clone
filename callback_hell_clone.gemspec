require_relative 'lib/callback_hell/version'

Gem::Specification.new do |spec|
  spec.name          = "callback_hell_clone"
  spec.version       = CallbackHell::VERSION
  spec.authors       = ["yasu551"]
  spec.email         = ["yasu551@example.com"]

  spec.summary       = "Analyze Ruby on Rails models for callback and validation insights"
  spec.description   = "Callback Hell is a Ruby gem that analyzes your Ruby on Rails application models and provides actionable insights on callbacks and validations. Use it to identify models that might benefit from refactoring, spot callback pollution from gems and associations, and keep your models clean and maintainable."
  spec.homepage      = "https://github.com/yasu551/callback_hell_clone"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/yasu551/callback_hell_clone"
  spec.metadata["changelog_uri"] = "https://github.com/yasu551/callback_hell_clone/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Dependencies
  spec.add_dependency "activesupport", ">= 5.0"
  spec.add_dependency "thor", "~> 1.0"
  spec.add_dependency "colorize", "~> 0.8"

  # Development dependencies
  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rubocop", "~> 1.0"
end