EXAMPLE_EMAIL = "ilia.gilderman+test115@gmail.com"
EXAMPLE_PASSWORD = "password"

def example_set_api_key
  Nurego.api_base = "http://localhost:31001"
  Nurego.api_key = "t2fd15a9-a6ca-46b3-9799-c4d21fab4fac"
end

def example_set_uaa_client
  Nurego.client_id = "portal"
  Nurego.client_secret = "portalsecret"
  Nurego.provider_site = "http://localhost:8080/uaa"
end