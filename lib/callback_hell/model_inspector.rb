require 'pathname'

module CallbackHell
  class ModelInspector
    CALLBACK_METHODS = %w[
      before_validation after_validation
      before_save after_save around_save
      before_create after_create around_create
      before_update after_update around_update
      before_destroy after_destroy around_destroy
      after_commit after_rollback
      after_initialize after_find
      before_touch after_touch
    ].freeze

    VALIDATION_METHODS = %w[
      validates validates_presence_of validates_absence_of
      validates_acceptance_of validates_confirmation_of
      validates_format_of validates_inclusion_of validates_exclusion_of
      validates_length_of validates_numericality_of validates_uniqueness_of
      validates_with validates_each validate
    ].freeze

    ASSOCIATION_METHODS = %w[
      belongs_to has_one has_many has_and_belongs_to_many
    ].freeze

    attr_reader :path, :content, :callbacks, :validations, :associations

    def initialize(path)
      @path = Pathname.new(path)
      @content = File.read(path) if @path.exist?
      @callbacks = []
      @validations = []
      @associations = []
      @analyzed = false
    end

    def analyze
      return if @analyzed || @content.nil?

      analyze_callbacks
      analyze_validations  
      analyze_associations
      @analyzed = true
    end

    def model_name
      basename = @path.basename.to_s.gsub(/\.rb$/, '')
      # Simple camelize implementation
      basename.split('_').map(&:capitalize).join
    end

    def has_callbacks?
      @callbacks.any?
    end

    def has_validations?
      @validations.any?
    end

    def callback_heavy?
      @callbacks.size >= 5
    end

    def validation_heavy?
      @validations.size >= 8
    end

    def potentially_polluted?
      # Check for gems that might add callbacks/validations
      gem_pollution_indicators.any? || association_callback_pollution?
    end

    def callback_count
      @callbacks.size
    end

    def validation_count
      @validations.size
    end

    def association_count
      @associations.size
    end

    private

    def analyze_callbacks
      CALLBACK_METHODS.each do |callback_method|
        matches = @content.scan(/^\s*#{Regexp.escape(callback_method)}\s+(.+)$/)
        matches.each do |match|
          @callbacks << {
            type: callback_method,
            definition: match[0].strip,
            line: find_line_number(callback_method, match[0])
          }
        end
      end
    end

    def analyze_validations
      VALIDATION_METHODS.each do |validation_method|
        matches = @content.scan(/^\s*#{Regexp.escape(validation_method)}\s+(.+)$/)
        matches.each do |match|
          @validations << {
            type: validation_method,
            definition: match[0].strip,
            line: find_line_number(validation_method, match[0])
          }
        end
      end
    end

    def analyze_associations
      ASSOCIATION_METHODS.each do |association_method|
        matches = @content.scan(/^\s*#{Regexp.escape(association_method)}\s+(.+)$/)
        matches.each do |match|
          @associations << {
            type: association_method,
            definition: match[0].strip,
            line: find_line_number(association_method, match[0])
          }
        end
      end
    end

    def find_line_number(method, definition)
      lines = @content.lines
      lines.each_with_index do |line, index|
        if line.include?(method) && line.include?(definition)
          return index + 1
        end
      end
      0
    end

    def gem_pollution_indicators
      indicators = []
      
      # Check for common gems that add callbacks/validations
      gem_patterns = {
        'acts_as_paranoid' => /acts_as_paranoid/,
        'paperclip' => /has_attached_file/,
        'carrierwave' => /mount_uploader/,
        'aasm' => /aasm|state_machine/,
        'friendly_id' => /friendly_id/,
        'acts_as_list' => /acts_as_list/,
        'acts_as_tree' => /acts_as_tree/,
        'paranoia' => /acts_as_paranoid/
      }

      gem_patterns.each do |gem_name, pattern|
        if @content.match?(pattern)
          indicators << gem_name
        end
      end

      indicators
    end

    def association_callback_pollution?
      # Check for associations with callbacks that might pollute the model
      callback_patterns = /dependent:\s*:(destroy|delete_all|nullify)/
      @content.match?(callback_patterns)
    end
  end
end