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
  class Reporter
    def initialize(analysis, options = {})
      @analysis = analysis
      @options = {
        color: true,
        verbose: false,
        format: :text
      }.merge(options)
    end

    def report
      case @options[:format]
      when :json
        json_report
      when :csv
        csv_report
      else
        text_report
      end
    end

    private

    def text_report
      output = []
      output << header
      output << summary
      output << "\n"
      output << callback_analysis
      output << "\n"
      output << validation_analysis
      output << "\n"
      output << pollution_analysis
      output << "\n"
      output << recommendations

      puts output.join("\n")
    end

    def header
      title = "🔥 CALLBACK HELL ANALYSIS REPORT 🔥"
      @options[:color] ? title.red.bold : title
    end

    def summary
      lines = []
      lines << "=" * 50
      lines << "SUMMARY"
      lines << "=" * 50
      lines << "Total models analyzed: #{@analysis[:total_models]}"
      lines << "Models with callbacks: #{@analysis[:models_with_callbacks].size}"
      lines << "Models with validations: #{@analysis[:models_with_validations].size}"
      lines << "Callback-heavy models: #{@analysis[:callback_heavy_models].size}"
      lines << "Validation-heavy models: #{@analysis[:validation_heavy_models].size}"
      lines << "Potentially polluted models: #{@analysis[:polluted_models].size}"
      
      if @options[:color]
        lines.map! { |line| line.include?("heavy") || line.include?("polluted") ? line.yellow : line.white }
      end
      
      lines.join("\n")
    end

    def callback_analysis
      lines = []
      lines << "CALLBACK ANALYSIS"
      lines << "-" * 20

      if @analysis[:callback_heavy_models].any?
        lines << "⚠️  CALLBACK-HEAVY MODELS (≥5 callbacks):".colorize(@options[:color] ? :yellow : :default)
        @analysis[:callback_heavy_models].each do |model|
          line = "  • #{model.model_name}: #{model.callback_count} callbacks"
          lines << (@options[:color] ? line.red : line)
          
          if @options[:verbose]
            model.callbacks.each do |callback|
              detail = "    - #{callback[:type]}: #{callback[:definition]}"
              lines << (@options[:color] ? detail.light_red : detail)
            end
          end
        end
      else
        lines << "✅ No callback-heavy models found"
      end

      lines.join("\n")
    end

    def validation_analysis
      lines = []
      lines << "VALIDATION ANALYSIS"
      lines << "-" * 20

      if @analysis[:validation_heavy_models].any?
        lines << "⚠️  VALIDATION-HEAVY MODELS (≥8 validations):".colorize(@options[:color] ? :yellow : :default)
        @analysis[:validation_heavy_models].each do |model|
          line = "  • #{model.model_name}: #{model.validation_count} validations"
          lines << (@options[:color] ? line.red : line)
          
          if @options[:verbose]
            model.validations.each do |validation|
              detail = "    - #{validation[:type]}: #{validation[:definition]}"
              lines << (@options[:color] ? detail.light_red : detail)
            end
          end
        end
      else
        lines << "✅ No validation-heavy models found"
      end

      lines.join("\n")
    end

    def pollution_analysis
      lines = []
      lines << "POLLUTION ANALYSIS"
      lines << "-" * 20

      if @analysis[:polluted_models].any?
        lines << "🚨 POTENTIALLY POLLUTED MODELS:".colorize(@options[:color] ? :red : :default)
        @analysis[:polluted_models].each do |model|
          line = "  • #{model.model_name}"
          lines << (@options[:color] ? line.yellow : line)
          
          if @options[:verbose]
            lines << "    Callbacks: #{model.callback_count}, Validations: #{model.validation_count}"
          end
        end
      else
        lines << "✅ No potentially polluted models found"
      end

      lines.join("\n")
    end

    def recommendations
      lines = []
      lines << "RECOMMENDATIONS"
      lines << "-" * 20

      if @analysis[:callback_heavy_models].any?
        lines << "📋 For callback-heavy models:"
        lines << "   - Consider extracting callback logic into service objects"
        lines << "   - Use observers for cross-cutting concerns"
        lines << "   - Break down complex callbacks into smaller, focused methods"
      end

      if @analysis[:validation_heavy_models].any?
        lines << "📋 For validation-heavy models:"
        lines << "   - Group related validations together"
        lines << "   - Consider custom validation methods for complex logic"
        lines << "   - Use form objects for context-specific validations"
      end

      if @analysis[:polluted_models].any?
        lines << "📋 For polluted models:"
        lines << "   - Review gem-added callbacks and validations"
        lines << "   - Consider if all functionality is needed"
        lines << "   - Move non-essential concerns to decorators or service layers"
      end

      if lines.empty?
        lines << "🎉 Your models look clean! Keep up the good work!"
      end

      lines.join("\n")
    end

    def json_report
      require 'json'
      
      report_data = {
        summary: {
          total_models: @analysis[:total_models],
          models_with_callbacks: @analysis[:models_with_callbacks].size,
          models_with_validations: @analysis[:models_with_validations].size,
          callback_heavy_models: @analysis[:callback_heavy_models].size,
          validation_heavy_models: @analysis[:validation_heavy_models].size,
          polluted_models: @analysis[:polluted_models].size
        },
        details: {
          callback_heavy_models: serialize_models(@analysis[:callback_heavy_models]),
          validation_heavy_models: serialize_models(@analysis[:validation_heavy_models]),
          polluted_models: serialize_models(@analysis[:polluted_models])
        }
      }

      puts JSON.pretty_generate(report_data)
    end

    def csv_report
      require 'csv'
      
      puts CSV.generate do |csv|
        csv << ["Model", "Callbacks", "Validations", "Associations", "Callback Heavy", "Validation Heavy", "Potentially Polluted"]
        
        @analysis[:all_models].each do |model|
          csv << [
            model.model_name,
            model.callback_count,
            model.validation_count,
            model.association_count,
            model.callback_heavy?,
            model.validation_heavy?,
            model.potentially_polluted?
          ]
        end
      end
    end

    def serialize_models(models)
      models.map do |model|
        {
          name: model.model_name,
          callbacks: model.callback_count,
          validations: model.validation_count,
          associations: model.association_count,
          callback_heavy: model.callback_heavy?,
          validation_heavy: model.validation_heavy?,
          potentially_polluted: model.potentially_polluted?
        }
      end
    end
  end
end