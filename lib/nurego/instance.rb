module Nurego
  class Instance < APIResource
    include Nurego::APIOperations::List

    def connectors
      Connector.all({:instance => id }, @api_key)
    end
  end
end
