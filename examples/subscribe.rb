require "nurego"
require "uuidtools"

Nurego.api_key = "t2fd15a9-a6ca-46b3-9799-c4d21fab4fac"
Nurego.api_base = "http://localhost:31001"

r = Nurego::Registration.create(
#  {email: "ilia.gilderman+test1+#{UUIDTools::UUID.random_create.to_s}@gmail.com"}
  {email: "ilia.gilderman+test114@gmail.com"}
)

puts "#{r.inspect}"

customer = r.complete(id: r.id, password: "password")

puts "#{customer.inspect}"

