require "nurego"
require "uuidtools"

require_relative "example_setup"

example_set_api_key

r = Nurego::Registration.create({email: EXAMPLE_EMAIL})
puts "#{r.inspect}"

customer = r.complete(id: r.id, password: EXAMPLE_PASSWORD)

puts "#{customer.inspect}"

