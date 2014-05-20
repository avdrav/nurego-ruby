require "uuidtools"
require "spec_helper"
require_relative "../../lib/nurego"

describe "Nurego" do
  before(:all) do


    @common = {}
  end


  it "can register" do
    registration = Nurego::Registration.create({email: EXAMPLE_EMAIL})
    customer = registration.complete(id: registration.id, password: EXAMPLE_PASSWORD)
    customer["email"].should == EXAMPLE_EMAIL
    customer["object"].should == "customer"
    @common[:customer] = customer


    offering = Nurego::Offering.current
    offering.plans.each do |plan|
      plan.features.each do |feature|
        puts feature.inspect
      end
    end
    puts "Done"

    plans = offering.plans.all
  end

  xit "can create new payment method" do
    setup_login_and_login

    org = @common[:customer].organizations
    pm = Nurego::PaymentMethod.create(organization: org[0].id, last4: '1234', exp_month: 5, exp_year: 2016, cc_token: 'token')
    puts "#{pm.inspect}"

    pm = org[0].paymentmethod
    puts "#{pm.inspect}"

    pm.cc_token = 'token2'
    pm.organization  = org[0].id
    pm.last4 = '1235'
    pm.exp_month = 6
    pm.exp_year = 2020
    new_pm = pm.save

    new_pm.cc_token.should == 'token2'
    puts "#{new_pm.inspect}"
  end

  xit "can create new connector" do
    setup_login_and_login

    org = @common[:customer].organizations
    puts "#{org.inspect}"
    instances = org[0].instances
    puts "#{instances.inspect}"
    connectors = instances[1].connectors
    puts "#{connectors.inspect}"
  end

  it "can retrieve offerings w/o segment (defaults to all)" do
    offering = Nurego::Offering.current
    offering[:plans].should_not be_nil
    @common[:offering] = offering
  end

  it "can retrieve plans for offering" do
    @plans = @common[:offering].plans.data[0].features
  end

  it "can reset the password" do
    pc = Nurego::PasswordReset.create({email: EXAMPLE_EMAIL})
    pc["object"].should == "passwordreset"
    id = pc[:id]

    pc = Nurego::PasswordReset.retrieve({id: pc[:id]})
    pc[:id].should == id
    pc[:email].should == EXAMPLE_EMAIL

    setup_login_and_login(true)

    pc1 = pc.complete({password: 'new password', current_password: EXAMPLE_PASSWORD})

    lambda {
      Nurego::Auth.login(EXAMPLE_EMAIL, EXAMPLE_PASSWORD)
    }.should raise_exception(Nurego::AuthenticationError)

    Nurego::Auth.login(EXAMPLE_EMAIL, 'new password')

    pc2 = pc1.delete
    pc2[:deleted].should == true
  end
end
