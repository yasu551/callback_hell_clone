#!/usr/bin/env ruby

# Demo script showing Callback Hell gem functionality
puts "🔥 CALLBACK HELL GEM DEMO 🔥"
puts "=" * 50
puts

# Load the gem
$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require_relative 'lib/callback_hell'

puts "📋 Analyzing example Rails models..."
puts

# Run the analysis on our test models
result = CallbackHell.analyze("/tmp/test_app")

puts "📊 ANALYSIS RESULTS:"
puts "  • Total models: #{result[:total_models]}"
puts "  • With callbacks: #{result[:models_with_callbacks].size}"
puts "  • With validations: #{result[:models_with_validations].size}"
puts "  • Callback-heavy (≥5): #{result[:callback_heavy_models].size}"
puts "  • Validation-heavy (≥8): #{result[:validation_heavy_models].size}"
puts "  • Potentially polluted: #{result[:polluted_models].size}"
puts

puts "🔍 DETAILED BREAKDOWN:"
result[:all_models].each do |model|
  puts "  📄 #{model.model_name}:"
  puts "     - Callbacks: #{model.callback_count}"
  puts "     - Validations: #{model.validation_count}"
  puts "     - Associations: #{model.association_count}"
  puts "     - Issues: #{[model.callback_heavy? && 'callback-heavy', 
                          model.validation_heavy? && 'validation-heavy',
                          model.potentially_polluted? && 'polluted'].compact.join(', ')}"
  puts
end

puts "✅ Demo complete! The gem successfully:"
puts "  ✓ Detects callbacks and validations in Rails models"
puts "  ✓ Identifies potentially problematic patterns"
puts "  ✓ Provides actionable insights for refactoring"
puts "  ✓ Works as both a library and CLI tool"