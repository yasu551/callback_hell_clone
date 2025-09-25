#!/usr/bin/env ruby

# Simple test runner without RSpec dependencies
$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)

require_relative 'lib/callback_hell'
require_relative 'lib/callback_hell/model_inspector'
require_relative 'lib/callback_hell/analyzer'

# Mock colorize for testing
class String
  def colorize(color); self; end
  def red; self; end
  def yellow; self; end
  def white; self; end
  def light_red; self; end
  def bold; self; end
end

# Simple test framework
class SimpleTest
  def self.run(description, &block)
    puts "Testing: #{description}"
    begin
      block.call
      puts "  ✅ PASSED"
    rescue => e
      puts "  ❌ FAILED: #{e.message}"
      puts "     #{e.backtrace.first}"
    end
  end
end

puts "Running Callback Hell Tests..."
puts "=" * 50

# Test version
SimpleTest.run "CallbackHell has version" do
  raise "No version" unless CallbackHell::VERSION
  raise "Version should be string" unless CallbackHell::VERSION.is_a?(String)
end

# Test analyzer with test files
SimpleTest.run "Analyzer can analyze test directory" do
  analyzer = CallbackHell::Analyzer.new("/tmp/test_app")
  result = analyzer.analyze
  raise "Result not a Hash" unless result.is_a?(Hash)
  raise "Should have total_models key" unless result.key?(:total_models)
  raise "Should find 3 models" unless result[:total_models] == 3
end

# Test model inspector
require 'tempfile'

SimpleTest.run "ModelInspector detects callbacks" do
  content = <<~RUBY
    class TestModel < ApplicationRecord
      before_save :callback1
      after_save :callback2
      before_create :callback3
      validates :name, presence: true
      has_many :items, dependent: :destroy
      acts_as_paranoid
    end
  RUBY

  file = Tempfile.new(['test', '.rb'])
  file.write(content)
  file.close

  inspector = CallbackHell::ModelInspector.new(file.path)
  inspector.analyze

  raise "Should detect 3 callbacks" unless inspector.callback_count == 3
  raise "Should have callbacks" unless inspector.has_callbacks?
  raise "Should detect validations" unless inspector.has_validations?
  raise "Should detect pollution" unless inspector.potentially_polluted?

  file.unlink
end

SimpleTest.run "ModelInspector handles simple models" do
  content = <<~RUBY
    class SimpleModel < ApplicationRecord
      validates :name, presence: true
    end
  RUBY

  file = Tempfile.new(['simple', '.rb'])
  file.write(content)
  file.close

  inspector = CallbackHell::ModelInspector.new(file.path)
  inspector.analyze

  raise "Should have 0 callbacks" unless inspector.callback_count == 0
  raise "Should have 1 validation" unless inspector.validation_count == 1
  raise "Should not be callback heavy" if inspector.callback_heavy?
  raise "Should not be validation heavy" if inspector.validation_heavy?

  file.unlink
end

SimpleTest.run "Model name extraction works" do
  inspector = CallbackHell::ModelInspector.new('/path/to/user_model.rb')
  raise "Should extract UserModel" unless inspector.model_name == 'UserModel'
  
  inspector2 = CallbackHell::ModelInspector.new('/path/to/user.rb')
  raise "Should extract User" unless inspector2.model_name == 'User'
end

# Test full analysis with example output
SimpleTest.run "Full analysis produces expected output" do
  analysis = CallbackHell.analyze("/tmp/test_app")
  
  expected_keys = [:total_models, :models_with_callbacks, :models_with_validations, 
                   :callback_heavy_models, :validation_heavy_models, :polluted_models, :all_models]
  
  expected_keys.each do |key|
    raise "Missing key: #{key}" unless analysis.key?(key)
  end

  raise "Should have models with callbacks" if analysis[:models_with_callbacks].empty?
  raise "Should have models with validations" if analysis[:models_with_validations].empty?
  raise "Should have callback heavy models" if analysis[:callback_heavy_models].empty?
  raise "Should have polluted models" if analysis[:polluted_models].empty?
end

puts
puts "=" * 50
puts "All tests completed! 🎉"