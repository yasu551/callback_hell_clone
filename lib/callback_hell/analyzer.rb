require 'pathname'

module CallbackHell
  class Analyzer
    attr_reader :path, :models

    def initialize(path = ".")
      @path = Pathname.new(path).expand_path
      @models = []
    end

    def analyze
      find_models
      analyze_models
      build_report
    end

    private

    def find_models
      model_paths = []
      
      # Look for models in typical Rails locations
      possible_paths = [
        @path.join("app", "models"),
        @path.join("models")
      ]

      # If neither exists, look in the path itself
      if possible_paths.none?(&:exist?)
        possible_paths = [@path] if @path.exist?
      end

      possible_paths.each do |search_path|
        if search_path.exist?
          model_paths.concat(Dir.glob(search_path.join("**/*.rb")))
        end
      end

      # Remove duplicates and create model inspectors
      model_paths.uniq.each do |model_path|
        @models << ModelInspector.new(model_path)
      end
    end

    def analyze_models
      @models.each(&:analyze)
    end

    def build_report
      {
        total_models: @models.size,
        models_with_callbacks: @models.select(&:has_callbacks?),
        models_with_validations: @models.select(&:has_validations?),
        callback_heavy_models: @models.select(&:callback_heavy?),
        validation_heavy_models: @models.select(&:validation_heavy?),
        polluted_models: @models.select(&:potentially_polluted?),
        all_models: @models
      }
    end
  end
end