require_relative '../lib/callback_hell/analyzer'
require_relative '../lib/callback_hell/model_inspector'

RSpec.describe CallbackHell::Analyzer do
  describe "#analyze" do
    it "analyzes models in a directory" do
      analyzer = CallbackHell::Analyzer.new("/tmp/test_app")
      result = analyzer.analyze

      expect(result).to be_a(Hash)
      expect(result).to have_key(:total_models)
      expect(result).to have_key(:models_with_callbacks)
      expect(result).to have_key(:models_with_validations)
      expect(result).to have_key(:callback_heavy_models)
      expect(result).to have_key(:validation_heavy_models)
      expect(result).to have_key(:polluted_models)
      expect(result).to have_key(:all_models)

      expect(result[:total_models]).to eq(3)
      expect(result[:models_with_callbacks].size).to be > 0
      expect(result[:models_with_validations].size).to be > 0
    end

    it "handles non-existent directories" do
      analyzer = CallbackHell::Analyzer.new("/non/existent/path")
      result = analyzer.analyze

      expect(result[:total_models]).to eq(0)
      expect(result[:models_with_callbacks]).to be_empty
      expect(result[:models_with_validations]).to be_empty
    end
  end
end