module Nurego
  class Organization < APIResource
    include Nurego::APIOperations::List
    include Nurego::APIOperations::Update

    def instances
      Instance.all({:organization => id }, @api_key)
    end
  end
end
