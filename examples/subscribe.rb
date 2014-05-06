require "nurego"
require "uuidtools"

require_relative "example_setup"

example_set_api_key
example_set_uaa_client

begin
  r = Nurego::Registration.create({email: EXAMPLE_EMAIL})
  puts "#{r.inspect}"

  customer = r.complete(id: r.id, password: EXAMPLE_PASSWORD)
  puts "#{customer.inspect}"

  Nurego::Auth.login(EXAMPLE_EMAIL, EXAMPLE_PASSWORD)

  c = Nurego::Customer.me
  puts "#{c.inspect}"

  c0 = Nurego::Customer.retrieve(id: c[:id])
  puts "#{c0.inspect}"

  plan_guid = c[:plan_id]
  Nurego::Customer.update_plan(plan_guid) # update to the same plan, as we don't know if there's more than one

  c = Nurego::Customer.me
  puts "#{c.inspect}"
  puts "account has plan" if !c[:plan_id].nil?

  Nurego::Customer.cancel_account
  c = Nurego::Customer.me
  puts "#{c.inspect}"

  puts "account cancelled" if c[:plan_id].nil?

rescue Nurego::NuregoError => e
  puts "ERROR #{e.error_code}"
end

