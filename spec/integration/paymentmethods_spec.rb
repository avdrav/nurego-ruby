require File.join(File.dirname(__FILE__), 'spec_helper')

describe "PaymentMethods" do
  before(:all) do
    setup_nurego_lib
    setup_login_and_login
  end

  it "can create a payment method" do
    # TODO: make the real token here

    customer = Nurego::Customer.me
    organization = customer.organizations[0]

    Nurego::PaymentMethod.create({   organization: organization["id"],
                                     payment_method: "cc",
                                     last4: "1234",
                                     exp_month: 5,
                                     exp_year: 2017,
                                     cc_token: "1234",
                                 })


    paymentmethod = organization.paymentmethod
    paymentmethod["object"].should == "paymentmethod"
  end
end
