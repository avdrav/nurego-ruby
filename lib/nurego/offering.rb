module Nurego
  class Offering < APIResource

    def self.retrieve(id, api_key=nil)
      raise NotImplementedError.new("Offering cannot be retrieved with ID. Retrieve an offering using Offering.current")
    end

    def self.current(params = {}, api_key = nil)
      response, api_key = Nurego.request(:get, self.url, api_key, params)
      Util.convert_to_nurego_object(response, api_key)
    end

    def plans
      Plan.all({:offering => id }, @api_key)
    end
  end
end
