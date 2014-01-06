require File.expand_path('../../test_helper', __FILE__)

describe "Nurego::Customer" do
  before(:each) do
    @mock = double
    Nurego.mock_rest_client = @mock
    Nurego.api_key="foo"
  end

  it "customers should be listable" do
    @mock.should_receive(:get).and_return(test_response(test_customer_array))
    c = Nurego::Customer.all
    c.kind_of?(Array).should be_true
    c[0].kind_of?(Nurego::Customer).should be_true
  end

  xit "customers should be deletable" do
    @mock.should_receive(:delete).once.and_return(test_response(test_customer({:deleted => true})))
    c = Nurego::Customer.new("test_customer")
    c.delete
    c.deleted.should be_true
  end

  xit "customers should be updateable" do
    @mock.should_receive(:get).once.and_return(test_response(test_customer({:mnemonic => "foo"})))
    @mock.should_receive(:post).once.and_return(test_response(test_customer({:mnemonic => "bar"})))
    c = Nurego::Customer.new("test_customer").refresh
    assert_equal c.mnemonic, "foo"
    c.mnemonic = "bar"
    c.save
    assert_equal c.mnemonic, "bar"
  end

  xit "create should return a new customer" do
    @mock.should_receive(:post).once.and_return(test_response(test_customer))
    c = Nurego::Customer.create
    assert_equal "c_test_customer", c.id
  end

  xit "be able to update a customer's subscription" do
    @mock.should_receive(:get).once.and_return(test_response(test_customer))
    c = Nurego::Customer.retrieve("test_customer")

    @mock.should_receive(:post).once.with do |url, api_key, params|
      url == "#{Nurego.api_base}/v1/customers/c_test_customer/subscription" && api_key.nil? && CGI.parse(params) == {'plan' => ['silver']}
    end.and_return(test_response(test_subscription('silver')))
    s = c.update_subscription({:plan => 'silver'})

    assert_equal 'subscription', s.object
    assert_equal 'silver', s.plan.identifier
  end

  xit "be able to cancel a customer's subscription" do
    @mock.should_receive(:get).once.and_return(test_response(test_customer))
    c = Nurego::Customer.retrieve("test_customer")

    # Not an accurate response, but whatever

    @mock.should_receive(:delete).once.with("#{Nurego.api_base}/v1/customers/c_test_customer/subscription?at_period_end=true", nil, nil).and_return(test_response(test_subscription('silver')))
    c.cancel_subscription({:at_period_end => 'true'})

    @mock.should_receive(:delete).once.with("#{Nurego.api_base}/v1/customers/c_test_customer/subscription", nil, nil).and_return(test_response(test_subscription('silver')))
    c.cancel_subscription
  end

  xit "be able to delete a customer's discount" do
    @mock.should_receive(:get).once.and_return(test_response(test_customer))
    c = Nurego::Customer.retrieve("test_customer")

    @mock.should_receive(:delete).once.with("#{Nurego.api_base}/v1/customers/c_test_customer/discount", nil, nil)
      .and_return(test_response(test_delete_discount_response))
    c.delete_discount
    assert_equal nil, c.discount
  end
end
