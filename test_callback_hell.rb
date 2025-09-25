#!/usr/bin/env ruby

# Add lib to path
$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)

# Test script for callback_hell without full dependencies
require_relative 'lib/callback_hell/version'
require_relative 'lib/callback_hell/model_inspector'
require_relative 'lib/callback_hell/analyzer'

# Mock colorize for testing
class String
  def colorize(color)
    self
  end

  def red
    self
  end

  def yellow
    self
  end

  def white
    self
  end

  def light_red
    self
  end

  def bold
    self
  end
end

# Simple reporter for testing
class SimpleReporter
  def initialize(analysis)
    @analysis = analysis
  end

  def report
    puts "🔥 CALLBACK HELL ANALYSIS REPORT 🔥"
    puts "=" * 50
    puts "SUMMARY"
    puts "=" * 50
    puts "Total models analyzed: #{@analysis[:total_models]}"
    puts "Models with callbacks: #{@analysis[:models_with_callbacks].size}"
    puts "Models with validations: #{@analysis[:models_with_validations].size}"
    puts "Callback-heavy models: #{@analysis[:callback_heavy_models].size}"
    puts "Validation-heavy models: #{@analysis[:validation_heavy_models].size}"
    puts "Potentially polluted models: #{@analysis[:polluted_models].size}"
    puts

    if @analysis[:callback_heavy_models].any?
      puts "⚠️  CALLBACK-HEAVY MODELS (≥5 callbacks):"
      @analysis[:callback_heavy_models].each do |model|
        puts "  • #{model.model_name}: #{model.callback_count} callbacks"
      end
      puts
    end

    if @analysis[:validation_heavy_models].any?
      puts "⚠️  VALIDATION-HEAVY MODELS (≥8 validations):"
      @analysis[:validation_heavy_models].each do |model|
        puts "  • #{model.model_name}: #{model.validation_count} validations"
      end
      puts
    end

    if @analysis[:polluted_models].any?
      puts "🚨 POTENTIALLY POLLUTED MODELS:"
      @analysis[:polluted_models].each do |model|
        puts "  • #{model.model_name}"
      end
      puts
    end

    puts "RECOMMENDATIONS:"
    if @analysis[:callback_heavy_models].any?
      puts "📋 For callback-heavy models:"
      puts "   - Consider extracting callback logic into service objects"
      puts "   - Use observers for cross-cutting concerns"
    end
    if @analysis[:validation_heavy_models].any?
      puts "📋 For validation-heavy models:"
      puts "   - Group related validations together"
      puts "   - Consider custom validation methods for complex logic"
    end
    if @analysis[:polluted_models].any?
      puts "📋 For polluted models:"
      puts "   - Review gem-added callbacks and validations"
      puts "   - Consider if all functionality is needed"
    end
    puts "✅ Analysis complete!"
  end
end

# Test the analyzer
puts "Testing Callback Hell Analyzer..."
puts

begin
  analyzer = CallbackHell::Analyzer.new("/tmp/test_app")
  analysis = analyzer.analyze
  
  reporter = SimpleReporter.new(analysis)
  reporter.report
rescue => e
  puts "Error: #{e.message}"
  puts e.backtrace
end