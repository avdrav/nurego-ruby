require File.join(File.dirname(__FILE__), 'spec_helper')

describe "Bills" do
  before(:all) do
    setup_nurego_lib
    setup_login_and_login
  end

  it "can fetch the bills form customer with no bill" do
    customer = Nurego::Customer.me
    organization = customer.organizations[0]
    bills = organization.bills
    bills["object"].should == "list"
    bills["count"].should == 0
  end

  xit "it can fetch bills" do
    # TODO: add bill and fetch it
  end
end
