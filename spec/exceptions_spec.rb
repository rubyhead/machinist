require File.dirname(__FILE__) + '/spec_helper'

RSpec.describe Machinist, "exceptions" do

  describe Machinist::BlueprintCantSaveError do
    it "presents the right message" do
      blueprint = Machinist::Blueprint.new(String) { }
      exception_message = Machinist::BlueprintCantSaveError.new(blueprint).message

      expect(exception_message)
        .to eq "make! is not supported by blueprints for class String"
    end
  end

  describe Machinist::NoBlueprintError do
    it "presents the right message" do
      exception_message = Machinist::NoBlueprintError.new(String, :master).message
      expect(exception_message)
        .to eq "No master blueprint defined for class String"
    end
  end

end
