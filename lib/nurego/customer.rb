module Nurego
  class Customer < APIResource
    def register(params)
      response, api_key = Nurego.request(:post, register_url, @api_key, params)
      refresh_from({ :subscription => response }, api_key, true)
      subscription
    end

    def new
    end

    def me
    end

    private

    def register_url
      url + '/register'
    end

    def new_url
      url + '/new'
    end

    def me_url
      url + '/me'
    end
  end
end
