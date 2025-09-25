require_relative 'callback_hell/version'
require_relative 'callback_hell/analyzer'
require_relative 'callback_hell/model_inspector'
require_relative 'callback_hell/reporter'
require_relative 'callback_hell/cli'

begin
  require 'active_support'
  require 'active_support/core_ext'
rescue LoadError
  # Fallback when ActiveSupport is not available - minimal implementation
  class String
    def camelize
      self.split('_').map(&:capitalize).join
    end
  end
end

begin
  require 'colorize'
rescue LoadError
  # Fallback for when colorize is not available
  class String
    def colorize(color)
      self
    end
    def red; self; end
    def yellow; self; end
    def white; self; end
    def light_red; self; end
    def bold; self; end
  end
end

module CallbackHell
  class Error < StandardError; end

  # Analyze Rails models for callback and validation insights
  def self.analyze(path = ".")
    analyzer = Analyzer.new(path)
    analyzer.analyze
  end

  # Quick analysis with default reporting
  def self.report(path = ".", options = {})
    analysis = analyze(path)
    reporter = Reporter.new(analysis, options)
    reporter.report
  end
end