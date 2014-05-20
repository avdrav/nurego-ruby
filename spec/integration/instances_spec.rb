require File.join(File.dirname(__FILE__), 'spec_helper')

describe "Instances" do
  before(:all) do
    setup_nurego_lib
    setup_login_and_login
  end

  it "can retrieve instances" do
    customer = Nurego::Customer.me
    organization = customer.organizations
    instances = organization[0].instances
    instances.size.should == 2
    instances.each do |instance|
      instance["object"] == "instance"
    end
  end

  xit "can retrieve connectors" do
    # PENDING on connector fix
    # TODO create real connector and fetch it
    customer = Nurego::Customer.me
    organization = customer.organizations
    instances = organization[0].instances
    instances.size.should == 2
    instances.each do |instance|
      connectors = instance.connectors
      connectors.each do |connector|
        connector["object"].should == "connector"
      end
    end
  end
end