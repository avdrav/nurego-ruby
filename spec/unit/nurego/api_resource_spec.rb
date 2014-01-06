# -*- coding: utf-8 -*-
require File.expand_path('../../test_helper', __FILE__)

describe "Nurego::ApiResource" do
  before(:each) do
    @mock = double
    Nurego.mock_rest_client = @mock
    Nurego.api_key="foo"
  end

  it "creating a new APIResource should not fetch over the network" do
    @mock.should_not_receive(:get)
    Nurego::Customer.new("someid")
  end

  it "creating a new APIResource from a hash should not fetch over the network" do
    @mock.should_not_receive(:get)
    Nurego::Customer.construct_from({
                                        :id => "somecustomer",
                                        :card => {:id => "somecard", :object => "card"},
                                        :object => "customer"
                                    })
  end

  it "setting an attribute should not cause a network request" do
    @mock.should_not_receive(:get)
    @mock.should_not_receive(:post)
    c = Nurego::Customer.new("test_customer");
    c.card = {:id => "somecard", :object => "card"}
  end

  it "accessing id should not issue a fetch" do
    @mock.should_not_receive(:get)
    c = Nurego::Customer.new("test_customer");
    c.id
  end

  it "not specifying api credentials should raise an exception" do
    Nurego.api_key = nil
    expect { Nurego::Customer.new("test_customer").refresh }.to raise_error(Nurego::AuthenticationError)
  end

  it "specifying api credentials containing whitespace should raise an exception" do
    Nurego.api_key = "key "
    expect { Nurego::Customer.new("test_customer").refresh }.to raise_error(Nurego::AuthenticationError)
  end

  it "specifying invalid api credentials should raise an exception" do
    Nurego.api_key = "invalid"
    response = test_response(test_invalid_api_key_error, 401)
    expect do
      @mock.should_receive(:get).and_raise(RestClient::ExceptionWithResponse.new(response, 401))
      Nurego::Customer.retrieve("failing_customer")
    end.to raise_error(Nurego::AuthenticationError)
  end

  it "AuthenticationErrors should have an http status, http body, and JSON body" do
    Nurego.api_key = "invalid"
    response = test_response(test_invalid_api_key_error, 401)
    begin
      @mock.should_receive(:get).and_raise(RestClient::ExceptionWithResponse.new(response, 401))
      Nurego::Customer.retrieve("failing_customer")
    rescue Nurego::AuthenticationError => e
      e.http_status.should eq(401)
      !!e.http_body.should(be_true)
      !!e.json_body[:error][:message].should(be_true)
      test_invalid_api_key_error['error']['message'].should eq(e.json_body[:error][:message])
    end
  end

  context "when specifying per-object credentials" do
    context "with no global API key set" do
      xit "use the per-object credential when creating" do
        Nurego.should_receive(:execute_request).with do |opts|
          opts[:headers][:authorization] == 'Bearer sk_test_local'
        end.and_return(test_response(test_charge))

        Nurego::Charge.create({:card => {:number => '4242424242424242'}},
                              'sk_test_local')
      end
    end

    context "with a global API key set" do
      before(:each) do
        Nurego.api_key = "global"
      end

      xit "use the per-object credential when creating" do
        Nurego.should_receive(:execute_request).with do |opts|
          opts[:headers][:authorization] == 'Bearer local'
        end.and_return(test_response(test_charge))

        Nurego::Charge.create({:card => {:number => '4242424242424242'}},
                              'local')
      end

      xit "use the per-object credential when retrieving and making other calls" do
        Nurego.should_receive(:execute_request).with do |opts|
          opts[:url] == "#{Nurego.api_base}/v1/charges/ch_test_charge" &&
              opts[:headers][:authorization] == 'Bearer local'
        end.and_return(test_response(test_charge))
        Nurego.should_receive(:execute_request).with do |opts|
          opts[:url] == "#{Nurego.api_base}/v1/charges/ch_test_charge/refund" &&
              opts[:headers][:authorization] == 'Bearer local'
        end.and_return(test_response(test_charge))

        ch = Nurego::Charge.retrieve('ch_test_charge', 'local')
        ch.refund
      end
    end
  end

  context "with valid credentials" do
    xit "urlencode values in GET params" do
      response = test_response(test_charge_array)
      @mock.should_receive(:get).with("#{Nurego.api_base}/v1/charges?customer=test%20customer", nil, nil).and_return(response)
      charges = Nurego::Charge.all(:customer => 'test customer').data
      assert charges.kind_of? Array
    end

    xit "construct URL properly with base query parameters" do
      response = test_response(test_invoice_customer_array)
      @mock.should_receive(:get).with("#{Nurego.api_base}/v1/invoices?customer=test_customer", nil, nil).and_return(response)
      invoices = Nurego::Invoice.all(:customer => 'test_customer')

      @mock.should_receive(:get).with("#{Nurego.api_base}/v1/invoices?customer=test_customer&paid=true", nil, nil).and_return(response)
      invoices.all(:paid => true)
    end

    it "a 400 should give an InvalidRequestError with http status, body, and JSON body" do
      response = test_response(test_missing_id_error, 400)
      @mock.should_receive(:get).and_raise(RestClient::ExceptionWithResponse.new(response, 404))
      begin
        Nurego::Customer.retrieve("foo")
      rescue Nurego::InvalidRequestError => e
        e.http_status.should eq(400)
        !!e.http_body.should(be_true)
        e.json_body.kind_of?(Hash).should be_true
      end
    end

    it "a 401 should give an AuthenticationError with http status, body, and JSON body" do
      response = test_response(test_missing_id_error, 401)
      @mock.should_receive(:get).and_raise(RestClient::ExceptionWithResponse.new(response, 404))
      begin
        Nurego::Customer.retrieve("foo")
      rescue Nurego::AuthenticationError => e
        e.http_status.should eq(401)
        !!e.http_body.should(be_true)
        e.json_body.kind_of?(Hash).should be_true
      end
    end

    it "a 402 should give a CardError with http status, body, and JSON body" do
      response = test_response(test_missing_id_error, 402)
      @mock.should_receive(:get).and_raise(RestClient::ExceptionWithResponse.new(response, 404))
      begin
        Nurego::Customer.retrieve("foo")
      rescue Nurego::CardError => e
        e.http_status.should eq(402)
        !!e.http_body.should(be_true)
        e.json_body.kind_of?(Hash).should be_true
      end
    end

    it "a 404 should give an InvalidRequestError with http status, body, and JSON body" do
      response = test_response(test_missing_id_error, 404)
      @mock.should_receive(:get).and_raise(RestClient::ExceptionWithResponse.new(response, 404))
      begin
        Nurego::Customer.retrieve("foo")
      rescue Nurego::InvalidRequestError => e
        e.http_status.should eq(404)
        !!e.http_body.should(be_true)
        e.json_body.kind_of?(Hash).should be_true
      end
    end

    xit "setting a nil value for a param should exclude that param from the request" do
      @mock.should_receive(:get).with do |url, api_key, params|
        uri = URI(url)
        query = CGI.parse(uri.query)
        (url =~ %r{^#{Nurego.api_base}/v1/charges?} &&
            query.keys.sort == ['offset', 'sad'])
      end.and_return(test_response({ :count => 1, :data => [test_charge] }))
      Nurego::Charge.all(:count => nil, :offset => 5, :sad => false)

      @mock.should_receive(:post).with do |url, api_key, params|
        url == "#{Nurego.api_base}/v1/charges" &&
            api_key.nil? &&
            CGI.parse(params) == { 'amount' => ['50'], 'currency' => ['usd'] }
      end.and_return(test_response({ :count => 1, :data => [test_charge] }))
      Nurego::Charge.create(:amount => 50, :currency => 'usd', :card => { :number => nil })
    end

    it "requesting with a unicode ID should result in a request" do
      response = test_response(test_missing_id_error, 404)
      @mock.should_receive(:get).with("#{Nurego.api_base}/v1/customers/%E2%98%83", nil, nil).and_raise(RestClient::ExceptionWithResponse.new(response, 404))
      c = Nurego::Customer.new("☃")
      expect { c.refresh }.to raise_error(Nurego::InvalidRequestError)
    end

    it "requesting with no ID should result in an InvalidRequestError with no request" do
      c = Nurego::Customer.new
      expect { c.refresh }.to raise_error(Nurego::InvalidRequestError)
    end

    xit "making a GET request with parameters should have a query string and no body" do
      params = { :limit => 1 }
      @mock.should_receive(:get).with("#{Nurego.api_base}/v1/charges?limit=1", nil, nil).and_return(test_response([test_charge]))
      Nurego::Charge.all(params)
    end

    xit "making a POST request with parameters should have a body and no query string" do
      params = { :amount => 100, :currency => 'usd', :card => 'sc_token' }
      @mock.should_receive(:post).once.with do |url, get, post|
        get.nil? && CGI.parse(post) == {'amount' => ['100'], 'currency' => ['usd'], 'card' => ['sc_token']}
      end.and_return(test_response(test_charge))
      Nurego::Charge.create(params)
    end

    it "loading an object should issue a GET request" do
      @mock.should_receive(:get).once.and_return(test_response(test_customer))
      c = Nurego::Customer.new("test_customer")
      c.refresh
    end

    xit "using array accessors should be the same as the method interface" do
      @mock.should_receive(:get).once.and_return(test_response(test_customer))
      c = Nurego::Customer.new("test_customer")
      c.refresh
      c.created.should eq(c[:created])
      c.created.should eq(c['created'])
      c['created'] = 12345
      c.created.should eq(12345)
    end

    xit "accessing a property other than id or parent on an unfetched object should fetch it" do
      @mock.should_receive(:get).once.and_return(test_response(test_customer))
      c = Nurego::Customer.new("test_customer")
      c.charges
    end

    xit "updating an object should issue a POST request with only the changed properties" do
      @mock.should_receive(:post).with do |url, api_key, params|
        url == "#{Nurego.api_base}/v1/customers/c_test_customer" && api_key.nil? && CGI.parse(params) == {'description' => ['another_mn']}
      end.once.returns(test_response(test_customer))
      c = Nurego::Customer.construct_from(test_customer)
      c.description = "another_mn"
      c.save
    end

    xit "updating should merge in returned properties" do
      @mock.should_receive(:post).once.and_return(test_response(test_customer))
      c = Nurego::Customer.new("c_test_customer")
      c.description = "another_mn"
      c.save
      assert_equal false, c.livemode
    end

    xit "deleting should send no props and result in an object that has no props other deleted" do
      @mock.should_not_receive(:get)
      @mock.should_not_receive(:post)
      @mock.should_receive(:delete).with("#{Nurego.api_base}/v1/customers/c_test_customer", nil, nil).once.and_return(test_response({ "id" => "test_customer", "deleted" => true }))

      c = Nurego::Customer.construct_from(test_customer)
      c.delete
      c.deleted.should be_true

      assert_raises NoMethodError do
        c.livemode
      end
    end

    xit "loading an object with properties that have specific types should instantiate those classes" do
      @mock.should_receive(:get).once.and_return(test_response(test_charge))
      c = Nurego::Charge.retrieve("test_charge")
      (c.card.kind_of?(Nurego::NuregoObject) && c.card.object == 'card').should be_true
    end

    xit "loading all of an APIResource should return an array of recursively instantiated objects" do
      @mock.should_receive(:get).once.and_return(test_response(test_charge_array))
      c = Nurego::Charge.all.data
      c.kind_of?(Array).should be_true
      c[0].kind_of?(Nurego::Charge).should be_true
      (c[0].card.kind_of?(Nurego::NuregoObject) && c[0].card.object == 'card').should be_true
    end

    context "error checking" do

      it "404s should raise an InvalidRequestError" do
        response = test_response(test_missing_id_error, 404)
        @mock.should_receive(:get).and_raise(RestClient::ExceptionWithResponse.new(response, 404))

        rescued = false
        begin
          Nurego::Customer.new("test_customer").refresh
          assert false #shouldn't get here either
        rescue Nurego::InvalidRequestError => e # we don't use assert_raises because we want to examine e
          rescued = true
          e.kind_of?(Nurego::InvalidRequestError).should be_true
          e.param.should eq("id")
          e.message.should eq("Missing id")
        end

        rescued.should be_true
      end

      it "5XXs should raise an APIError" do
        response = test_response(test_api_error, 500)
        @mock.should_receive(:get).once.and_raise(RestClient::ExceptionWithResponse.new(response, 500))

        rescued = false
        begin
          Nurego::Customer.new("test_customer").refresh
          fail
        rescue Nurego::APIError => e # we don't use assert_raises because we want to examine e
          rescued = true
          e.kind_of?(Nurego::APIError).should be_true
        end

        rescued.should be_true
      end

    end
  end
end
