module Nurego
  class Entitlement < APIResource
    include Nurego::APIOperations::List
    include Nurego::APIOperations::Create

    def initialize(id=nil, api_key=nil, provider_name=nil)
      super(id, api_key)
      @provider_name = provider_name
    end

    def set_usage(feature_id, amount)
      payload = {
          feature_id: feature_id,
          organization: id,
          amount: amount,
          provider_name: @provider_name
      }
      response, api_key = Nurego.request(:put, "/v1/entitlements/usage", nil, payload)
    end

    def is_allowed(feature_id, requested_amount)
      payload =  {
          :organization => id,
          :feature_id => feature_id,
          :requested_amount => requested_amount,
          :provider_name => @provider_name
      }
      response, api_key = Nurego.request(:get, "/v1/entitlements/allowed", nil, payload)
      Util.convert_to_nurego_object(response, api_key)
    end

  end
end
