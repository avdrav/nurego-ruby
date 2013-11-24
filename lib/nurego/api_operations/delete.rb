module Nurego
  module APIOperations
    module Delete
      def delete
        response, api_key = Nurego.request(:delete, url, @api_key)
        refresh_from(response, api_key)
        self
      end
    end
  end
end
