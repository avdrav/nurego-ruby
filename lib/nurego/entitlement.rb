module Nurego
  class Entitlement < APIResource
    include Nurego::APIOperations::List
    include Nurego::APIOperations::Update

    def self.set_usage(organization, feature_id, amount)
      payload = {
          feature_id: feature_id,
          organization: organization,
          amount: amount
      }
      response, api_key = Nurego.request(:put, "/v1/entitlements/usage", nil, payload)
    end

    def self.is_allowed(organization, feature_id, amount)
      url = "/v1/entitlements/allowed?organization=#{organization}&feature_id=#{feature_id}&amount=#{amount}"
      response, api_key = Nurego.request(:get, url, nil, {})
      Util.convert_to_nurego_object(response, api_key)
    end

  end
end
