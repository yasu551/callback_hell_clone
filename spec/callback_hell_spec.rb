require_relative '../lib/callback_hell'

# Mock dependencies for testing
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

RSpec.describe CallbackHell do
  it "has a version number" do
    expect(CallbackHell::VERSION).not_to be nil
  end

  it "can analyze a directory" do
    result = CallbackHell.analyze("/tmp/test_app")
    expect(result).to be_a(Hash)
    expect(result[:total_models]).to be > 0
  end
end