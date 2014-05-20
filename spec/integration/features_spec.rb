require File.join(File.dirname(__FILE__), 'spec_helper')

describe "Features" do
  before(:all) do
    setup_nurego_lib
    setup_login_and_login
  end

  it "can retrieve features from plan" do
    offering = Nurego::Offering.current
    offering.plans.each do |plan|
      plan.features.each do |feature|
        feature["object"].should == "feature"
      end
    end
  end
end

