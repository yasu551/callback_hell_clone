require_relative '../lib/callback_hell/model_inspector'
require 'tempfile'

RSpec.describe CallbackHell::ModelInspector do
  let(:model_content) do
    <<~RUBY
      class TestModel < ApplicationRecord
        before_save :callback1
        after_save :callback2
        before_create :callback3
        after_create :callback4
        before_update :callback5

        validates :name, presence: true
        validates :email, uniqueness: true
        validates_presence_of :description
        validate :custom_validation

        has_many :items, dependent: :destroy
        belongs_to :category
        
        acts_as_paranoid
        
        private
        
        def callback1; end
        def callback2; end
        def callback3; end
        def callback4; end
        def callback5; end
        def custom_validation; end
      end
    RUBY
  end

  let(:simple_model_content) do
    <<~RUBY
      class SimpleModel < ApplicationRecord
        validates :name, presence: true
        has_many :items
      end
    RUBY
  end

  describe "#analyze" do
    it "detects callbacks in a model file" do
      file = Tempfile.new(['test_model', '.rb'])
      file.write(model_content)
      file.close

      inspector = CallbackHell::ModelInspector.new(file.path)
      inspector.analyze

      expect(inspector.callback_count).to eq(5)
      expect(inspector.has_callbacks?).to be true
      expect(inspector.callback_heavy?).to be true
    ensure
      file.unlink
    end

    it "detects validations in a model file" do
      file = Tempfile.new(['test_model', '.rb'])
      file.write(model_content)
      file.close

      inspector = CallbackHell::ModelInspector.new(file.path)
      inspector.analyze

      expect(inspector.validation_count).to eq(4)
      expect(inspector.has_validations?).to be true
      expect(inspector.validation_heavy?).to be false # 4 < 8
    ensure
      file.unlink
    end

    it "detects pollution indicators" do
      file = Tempfile.new(['test_model', '.rb'])
      file.write(model_content)
      file.close

      inspector = CallbackHell::ModelInspector.new(file.path)
      inspector.analyze

      expect(inspector.potentially_polluted?).to be true
    ensure
      file.unlink
    end

    it "handles simple models without callbacks" do
      file = Tempfile.new(['simple_model', '.rb'])
      file.write(simple_model_content)
      file.close

      inspector = CallbackHell::ModelInspector.new(file.path)
      inspector.analyze

      expect(inspector.callback_count).to eq(0)
      expect(inspector.validation_count).to eq(1)
      expect(inspector.has_callbacks?).to be false
      expect(inspector.callback_heavy?).to be false
      expect(inspector.validation_heavy?).to be false
    ensure
      file.unlink
    end
  end

  describe "#model_name" do
    it "extracts model name from file path" do
      inspector = CallbackHell::ModelInspector.new('/path/to/user_model.rb')
      expect(inspector.model_name).to eq('UserModel')
    end

    it "handles simple file names" do
      inspector = CallbackHell::ModelInspector.new('/path/to/user.rb')
      expect(inspector.model_name).to eq('User')
    end
  end
end