require "nurego"
require "uuidtools"

require_relative "example_setup"

example_set_api_key
example_set_uaa_client

begin

  Nurego::Auth.login(EXAMPLE_EMAIL, EXAMPLE_PASSWORD)

  c = Nurego::Customer.me
  c0 = Nurego::Customer.retrieve(id: c[:id])
  puts "#{c0.inspect}"

  o = c.organizations
  puts "#{o.inspect}"

  o0 = Nurego::Organization.retrieve(id: o[0][:id])
  puts "#{o0.inspect}"

  ents = o[0].entitlements
  puts "#{ents.inspect}"

  customers_ent = o[0].entitlements('imported_customers')
  puts "#{customers_ent.inspect}"

  feature_id = customers_ent[0][:id]
  max_amount = customers_ent[0][:max_allowed_amount]
  ent = Nurego::Entitlement.new({id: o[0][:id]})

  ent.set_usage(feature_id, max_amount - 1)

  allowed = ent.is_allowed(feature_id, 1)
  puts "#{allowed.inspect}"

  allowed = ent.is_allowed(feature_id, 2)
  puts "#{allowed.inspect}"

rescue Nurego::NuregoError => e
  puts "ERROR #{e.error_code}"
end

