module Nurego
  class Organization < APIResource
    include Nurego::APIOperations::List
    include Nurego::APIOperations::Update

    def instances
      Instance.all({:organization => id }, @api_key)
    end

    def paymentmethod
      PaymentMethod.all({:organization => id}, @api_key)
    end

    def bills
      Bill.all({ :organization => id }, @api_key)[:bills]
    end

    def entitlements(feature_id = nil, external_id = nil)
      if external_id
        Entitlement.all({:organization => external_id, :feature_id => feature_id }, @api_key)
      else
        Entitlement.all({:organization => id, :feature_id => feature_id, :provider_name => 'internal' }, @api_key)
      end
    end

  end
end
