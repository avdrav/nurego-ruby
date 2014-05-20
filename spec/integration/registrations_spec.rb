require File.join(File.dirname(__FILE__), 'spec_helper')

describe "Registrations" do
  before(:all) do
    EMAIL = "integration.test+#{UUIDTools::UUID.random_create.to_s}@openskymarkets.com"

    setup_nurego_lib(true)
  end

  it "can register a subscriber" do
    registration = Nurego::Registration.create({email: EMAIL})
    customer = registration.complete(id: registration.id, password: EXAMPLE_PASSWORD)
    customer["email"].should == EMAIL
    customer["object"].should == "customer"
  end
end
