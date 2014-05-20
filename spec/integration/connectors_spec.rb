require File.join(File.dirname(__FILE__), 'spec_helper')

describe "Connectors" do
  before(:all) do
    setup_nurego_lib
    setup_login_and_login
  end

  it "can create new connector" do
    customer = Nurego::Customer.me
    organization = customer.organizations
    puts "#{organization.inspect}"
    instances = organization[0].instances
    puts "#{instances.inspect}"
    connectors = instances[1].connectors
    puts "#{connectors.inspect}"
  end
end
