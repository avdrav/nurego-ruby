module Nurego
  class PasswordReset < APIResource
    include Nurego::APIOperations::Create
    include Nurego::APIOperations::Delete
    include Nurego::APIOperations::List
  end
end
