require 'uuidtools'
require_relative "../../lib/nurego"

EXAMPLE_EMAIL = "integration.test+#{UUIDTools::UUID.random_create.to_s}@openskymarkets.com"
EXAMPLE_PASSWORD = "password"

def setup_nurego_lib(no_register = false)
  Nurego.api_base = ENV['API_BASE'] || "http://localhost:31001/"
  Nurego.api_key = ENV['NUREGO_API_KEY_TEST'] || 'tee00d77-d6f2-4f8d-8897-26fb89fbeb34'

  register unless no_register
end

def setup_login_and_login(no_login = false)
  Nurego::Auth.client_id = "portal"
  Nurego::Auth.client_secret = ENV['PORTALSECRET'] || "portalsecret"
  Nurego::Auth.provider_site = ENV['UAA_URL'] || "http://localhost:8080/uaa"

  Nurego::Auth.login(EXAMPLE_EMAIL, EXAMPLE_PASSWORD) unless no_login
end

def register
  return if ENV['CUSTOMER_SET'] == "yes"

  registration = Nurego::Registration.create({email: EXAMPLE_EMAIL})
  customer = registration.complete(id: registration.id, password: EXAMPLE_PASSWORD)
  ENV['CUSTOMER_SET'] = (customer["email"] == EXAMPLE_EMAIL && customer["object"] == "customer") ? "yes" : "no"
end