module Nurego
  class Registration < APIResource
    include Nurego::APIOperations::Create
    include Nurego::APIOperations::List

    def complete(params)
      response, api_key = Nurego.request(:post, complete_url, @api_key, params)
      refresh_from({customer: response}, api_key, true)
      customer
    end

    private

    def complete_url
      url + '/complete'
    end
  end
end
