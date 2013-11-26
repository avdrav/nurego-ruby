module Nurego
  class Organization < APIResource
    include Nurego::APIOperations::List
    include Nurego::APIOperations::Update
  end
end
