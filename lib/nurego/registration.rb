module Nurego
  class Registration < APIResource
    include Nurego::APIOperations::Create

    def self.complete(params)
      response, api_key = Nurego.request(:post, complete_url, @api_key, params)
      refresh_from({customer: response}, api_key, true)
      customer
    end

    private

    def self.complete_url
      url + '/complete'
    end
  end
end
