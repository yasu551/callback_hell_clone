begin
  require 'thor'
  THOR_AVAILABLE = true
rescue LoadError
  THOR_AVAILABLE = false
end

module CallbackHell
  class CLI
    if THOR_AVAILABLE
      class ThorCLI < Thor
        desc "analyze [PATH]", "Analyze Rails models for callback and validation insights"
        method_option :verbose, type: :boolean, aliases: "-v", desc: "Show detailed analysis"
        method_option :format, type: :string, default: "text", desc: "Output format (text, json, csv)"
        method_option :no_color, type: :boolean, desc: "Disable colored output"
        def analyze(path = ".")
          options_hash = {
            verbose: options[:verbose],
            format: options[:format].to_sym,
            color: !options[:no_color]
          }

          begin
            analysis = CallbackHell.analyze(path)
            reporter = Reporter.new(analysis, options_hash)
            reporter.report
          rescue => e
            puts "Error analyzing models: #{e.message}".colorize(:red)
            exit 1
          end
        end

        desc "version", "Show version"
        def version
          puts CallbackHell::VERSION
        end

        default_task :analyze
      end
    end

    def self.start(args)
      if THOR_AVAILABLE
        ThorCLI.start(args)
      else
        # Simple CLI when Thor is not available
        path = args.first || "."
        verbose = args.include?("--verbose") || args.include?("-v")
        
        if args.include?("version") || args.include?("--version")
          puts CallbackHell::VERSION
          return
        end

        puts "Analyzing models in: #{path}"
        puts "(Thor gem not available - using simplified CLI)"
        puts

        begin
          analysis = CallbackHell.analyze(path)
          
          # Simple reporter output
          puts "🔥 CALLBACK HELL ANALYSIS REPORT 🔥"
          puts "=" * 50
          puts "Total models analyzed: #{analysis[:total_models]}"
          puts "Models with callbacks: #{analysis[:models_with_callbacks].size}"
          puts "Models with validations: #{analysis[:models_with_validations].size}"
          puts "Callback-heavy models: #{analysis[:callback_heavy_models].size}"
          puts "Validation-heavy models: #{analysis[:validation_heavy_models].size}"
          puts "Potentially polluted models: #{analysis[:polluted_models].size}"
          puts

          if analysis[:callback_heavy_models].any?
            puts "⚠️  CALLBACK-HEAVY MODELS:"
            analysis[:callback_heavy_models].each do |model|
              puts "  • #{model.model_name}: #{model.callback_count} callbacks"
            end
            puts
          end

          if analysis[:validation_heavy_models].any?
            puts "⚠️  VALIDATION-HEAVY MODELS:"
            analysis[:validation_heavy_models].each do |model|
              puts "  • #{model.model_name}: #{model.validation_count} validations"
            end
            puts
          end

          if analysis[:polluted_models].any?
            puts "🚨 POTENTIALLY POLLUTED MODELS:"
            analysis[:polluted_models].each do |model|
              puts "  • #{model.model_name}"
            end
            puts
          end

          puts "✅ Analysis complete!"
        rescue => e
          puts "Error analyzing models: #{e.message}"
          puts e.backtrace if verbose
          exit 1
        end
      end
    end
  end
end