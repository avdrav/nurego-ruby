require "nurego"
require "uuidtools"

require_relative "example_setup"

example_set_api_key
example_set_uaa_client

Nurego.login(EXAMPLE_EMAIL, EXAMPLE_PASSWORD)
#puts "#{Nurego.access_token}"

c = Nurego::Customer.me
puts "#{c.inspect}"
c0 = Nurego::Customer.retrieve(id: c[:id])
puts "#{c0.inspect}"

o = c.organizations

puts "#{o.inspect}"

o0 = Nurego::Organization.retrieve(id: o[0][:id])
puts "#{o0.inspect}"

o0[:name] = "new name"
o0.save
o0 = Nurego::Organization.retrieve(id: o0[:id])
puts "#{o0.inspect}"

i = o[0].instances
puts "#{i.inspect}"

i0 = Nurego::Instance.retrieve(id: i[0][:id])
puts "#{i0.inspect}"

con = i[1].connectors

puts "#{con.inspect}"

con0 = Nurego::Connector.retrieve(id: con[0][:id])
puts "#{con0.inspect}"

bills = o0.bills

puts "#{bills.inspect}"

bill = Nurego::Bill.retrieve(id: bills[:data][0][:id]) if bills[:count] > 0

puts "#{bill.inspect}" if bill

