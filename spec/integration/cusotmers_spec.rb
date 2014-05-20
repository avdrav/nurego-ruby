require File.join(File.dirname(__FILE__), 'spec_helper')

describe "Customers" do
  before(:all) do
    setup_nurego_lib
    setup_login_and_login
  end

  it "can fetch logged in customer" do
    customer = Nurego::Customer.me
    customer["object"].should == "customer"
    customer["email"].should == EXAMPLE_EMAIL
  end

  it "can retrieve customer by id" do
    customer = Nurego::Customer.me

    customer0 = Nurego::Customer.retrieve(id: customer[:id])
    customer0["email"] == EXAMPLE_EMAIL
  end

  it "can retrieve organization from customer" do
    customer = Nurego::Customer.me
    organization = customer.organizations[0]
    organization["object"].should == "organization"
  end

  it "can update the plan to the same plan" do
    customer = Nurego::Customer.me

    plan_guid = customer[:plan_id]
    Nurego::Customer.update_plan(plan_guid) # update to the same plan, as we don't know if there's more than one

    customer = Nurego::Customer.me
    customer[:plan_id].should_not be_nil
  end

  xit "can update the plan to different plan" do
    # TODO : update to the different plan
  end

  it "can cancel the customer account" do
    Nurego::Customer.cancel_account
    customer = Nurego::Customer.me
    customer[:plan_id].should be_nil

    ENV['CUSTOMER_SET'] = "no"

    # TODO find a way to set it w/o warning
    EXAMPLE_EMAIL = "integration.test+#{UUIDTools::UUID.random_create.to_s}@openskymarkets.com"
  end
end
