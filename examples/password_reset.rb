require "nurego"
require "uuidtools"

require_relative "example_setup"

example_set_api_key
example_set_uaa_client

Nurego.login(EXAMPLE_EMAIL, EXAMPLE_PASSWORD)

pc = Nurego::PasswordReset.create({email: EXAMPLE_EMAIL})
puts "#{pc.inspect}"

pc = Nurego::PasswordReset.retrieve({id: pc[:id]})
puts "#{pc.inspect}"

pc1 = pc.delete
puts "#{pc1.inspect}"
