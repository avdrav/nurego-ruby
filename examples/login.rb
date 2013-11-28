require "nurego"
require "uuidtools"

Nurego.client_id = "portal"
Nurego.client_secret = "portalsecret"
Nurego.provider_site = "http://localhost:8080/uaa"
Nurego.api_base = "http://localhost:31001"
Nurego.api_key = "t2fd15a9-a6ca-46b3-9799-c4d21fab4fac"

Nurego.login("ilia.gilderman+test114@gmail.com", "password")

#puts "#{Nurego.access_token}"

c = Nurego::Customer.me
puts "#{c.inspect}"
c0 = Nurego::Customer.retrieve(id: c[:id])
puts "#{c0.inspect}"

o = c.organizations

puts "#{o.inspect}"

o0 = Nurego::Organization.retrieve(id: o[0][:id])
puts "#{o0.inspect}"

i = o[0].instances
puts "#{i.inspect}"

i0 = Nurego::Instance.retrieve(id: i[0][:id])
puts "#{i0.inspect}"

con = i[1].connectors

puts "#{con.inspect}"

con0 = Nurego::Connector.retrieve(id: con[0][:id])
puts "#{con0.inspect}"
