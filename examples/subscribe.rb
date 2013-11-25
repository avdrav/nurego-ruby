require "nurego"

Nurego.api_key = "t2fd15a9-a6ca-46b3-9799-c4d21fab4fac"
Nurego.api_base = "http://localhost:31001"

Nurego::Customer.register(
  {email: "ilia.gilderman+test1@gmail.com"}
)
