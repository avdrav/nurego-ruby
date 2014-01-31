module Nurego
  class PaymentMethod < APIResource
    include Nurego::APIOperations::Create
    include Nurego::APIOperations::Update
    include Nurego::APIOperations::List

    def url
      PaymentMethod.url
    end

    def self.retrieve(id, api_key = nil)
      raise NotImplementedError.new("Payment Method cannot be retrieved without a organization ID. Retrieve a paymentmethod using organization.paymentmethod")
    end

  end
end
