require File.join(File.dirname(__FILE__), 'spec_helper')

describe "PasswordReset" do
  before(:all) do
    setup_nurego_lib
  end

  after(:all) do
    pc = Nurego::PasswordReset.create({email: EXAMPLE_EMAIL})
    pc = Nurego::PasswordReset.retrieve({id: pc[:id]})
    pc1 = pc.complete({password: EXAMPLE_PASSWORD, current_password: "new password"})
    pc1.delete
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