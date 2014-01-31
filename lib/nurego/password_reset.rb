module Nurego
  class PasswordReset < APIResource
    include Nurego::APIOperations::Create
    include Nurego::APIOperations::Delete
    include Nurego::APIOperations::List

    include Nurego::Auth

    def complete(params)
      Nurego::Auth.change_password(self.customer_id, params[:password], params[:current_password])
      self
    end
  end
end
