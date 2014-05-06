EXAMPLE_EMAIL = "PLEASE CHANGE TO NEW UNIQUE EMAIL YOU WILL USE FOR REGISTER"
EXAMPLE_PASSWORD = "password"

def example_set_api_key
  Nurego.api_base = "http://localhost:31001"
  Nurego.api_key = "YOUR INSTANCE KEY"
end

def example_set_uaa_client
  Nurego::Auth.client_id = "portal"
  Nurego::Auth.client_secret = "portalsecret"
  Nurego::Auth.provider_site = "http://localhost:8080/uaa"
end
