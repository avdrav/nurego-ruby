module Nurego
  class Plan < APIResource
    include Nurego::APIOperations::List

    def features
      Features.all({:plan => id }, @api_key)
    end
  end
end
