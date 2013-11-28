module Nurego
  class Customer < APIResource
    include Nurego::APIOperations::Create
    include Nurego::APIOperations::List

    def self.me(api_key = nil)
      response, api_key = Nurego.request(:get, me_url, api_key)
      Util.convert_to_nurego_object(response, api_key)
    end

    def organizations
      Organization.all({:customer => id }, @api_key)
    end

    def self.me_url
      '/v1/customers/me'
    end
  end
end
