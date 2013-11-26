require "nurego"
require "uuidtools"

Nurego.client_id = "portal"
Nurego.client_secret = "portalsecret"
Nurego.provider_site = "http://localhost:8080/uaa"
Nurego.api_base = "http://localhost:31001"
Nurego.api_key = "t2fd15a9-a6ca-46b3-9799-c4d21fab4fac"

Nurego.login("ilia.gilderman+test1@gmail.com", "password")

#puts "#{Nurego.access_token}"

c = Nurego::Customer.me

puts "#{c.inspect}"

