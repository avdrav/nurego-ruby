module Nurego
  class Connector < APIResource
    include Nurego::APIOperations::Create
    include Nurego::APIOperations::Update
    include Nurego::APIOperations::List
  end
end
