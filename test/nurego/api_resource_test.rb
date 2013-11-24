# -*- coding: utf-8 -*-
require File.expand_path('../../test_helper', __FILE__)

module Nurego
  class ApiResourceTest < Test::Unit::TestCase
    should "creating a new APIResource should not fetch over the network" do
      @mock.expects(:get).never
      Nurego::Customer.new("someid")
    end

    should "creating a new APIResource from a hash should not fetch over the network" do
      @mock.expects(:get).never
      Nurego::Customer.construct_from({
        :id => "somecustomer",
        :card => {:id => "somecard", :object => "card"},
        :object => "customer"
      })
    end

    should "setting an attribute should not cause a network request" do
      @mock.expects(:get).never
      @mock.expects(:post).never
      c = Nurego::Customer.new("test_customer");
      c.card = {:id => "somecard", :object => "card"}
    end

    should "accessing id should not issue a fetch" do
      @mock.expects(:get).never
      c = Nurego::Customer.new("test_customer");
      c.id
    end

    should "not specifying api credentials should raise an exception" do
      Nurego.api_key = nil
      assert_raises Nurego::AuthenticationError do
        Nurego::Customer.new("test_customer").refresh
      end
    end

    should "specifying api credentials containing whitespace should raise an exception" do
      Nurego.api_key = "key "
      assert_raises Nurego::AuthenticationError do
        Nurego::Customer.new("test_customer").refresh
      end
    end

    should "specifying invalid api credentials should raise an exception" do
      Nurego.api_key = "invalid"
      response = test_response(test_invalid_api_key_error, 401)
      assert_raises Nurego::AuthenticationError do
        @mock.expects(:get).once.raises(RestClient::ExceptionWithResponse.new(response, 401))
        Nurego::Customer.retrieve("failing_customer")
      end
    end

    should "AuthenticationErrors should have an http status, http body, and JSON body" do
      Nurego.api_key = "invalid"
      response = test_response(test_invalid_api_key_error, 401)
      begin
        @mock.expects(:get).once.raises(RestClient::ExceptionWithResponse.new(response, 401))
        Nurego::Customer.retrieve("failing_customer")
      rescue Nurego::AuthenticationError => e
        assert_equal(401, e.http_status)
        assert_equal(true, !!e.http_body)
        assert_equal(true, !!e.json_body[:error][:message])
        assert_equal(test_invalid_api_key_error['error']['message'], e.json_body[:error][:message])
      end
    end

    context "when specifying per-object credentials" do
      context "with no global API key set" do
        should "use the per-object credential when creating" do
          Nurego.expects(:execute_request).with do |opts|
            opts[:headers][:authorization] == 'Bearer sk_test_local'
          end.returns(test_response(test_charge))

          Nurego::Charge.create({:card => {:number => '4242424242424242'}},
            'sk_test_local')
        end
      end

      context "with a global API key set" do
        setup do
          Nurego.api_key = "global"
        end

        teardown do
          Nurego.api_key = nil
        end

        should "use the per-object credential when creating" do
          Nurego.expects(:execute_request).with do |opts|
            opts[:headers][:authorization] == 'Bearer local'
          end.returns(test_response(test_charge))

          Nurego::Charge.create({:card => {:number => '4242424242424242'}},
            'local')
        end

        should "use the per-object credential when retrieving and making other calls" do
          Nurego.expects(:execute_request).with do |opts|
            opts[:url] == "#{Nurego.api_base}/v1/charges/ch_test_charge" &&
              opts[:headers][:authorization] == 'Bearer local'
          end.returns(test_response(test_charge))
          Nurego.expects(:execute_request).with do |opts|
            opts[:url] == "#{Nurego.api_base}/v1/charges/ch_test_charge/refund" &&
              opts[:headers][:authorization] == 'Bearer local'
          end.returns(test_response(test_charge))

          ch = Nurego::Charge.retrieve('ch_test_charge', 'local')
          ch.refund
        end
      end
    end

    context "with valid credentials" do
      should "urlencode values in GET params" do
        response = test_response(test_charge_array)
        @mock.expects(:get).with("#{Nurego.api_base}/v1/charges?customer=test%20customer", nil, nil).returns(response)
        charges = Nurego::Charge.all(:customer => 'test customer').data
        assert charges.kind_of? Array
      end

      should "construct URL properly with base query parameters" do
        response = test_response(test_invoice_customer_array)
        @mock.expects(:get).with("#{Nurego.api_base}/v1/invoices?customer=test_customer", nil, nil).returns(response)
        invoices = Nurego::Invoice.all(:customer => 'test_customer')

        @mock.expects(:get).with("#{Nurego.api_base}/v1/invoices?customer=test_customer&paid=true", nil, nil).returns(response)
        invoices.all(:paid => true)
      end

      should "a 400 should give an InvalidRequestError with http status, body, and JSON body" do
        response = test_response(test_missing_id_error, 400)
        @mock.expects(:get).once.raises(RestClient::ExceptionWithResponse.new(response, 404))
        begin
          Nurego::Customer.retrieve("foo")
        rescue Nurego::InvalidRequestError => e
          assert_equal(400, e.http_status)
          assert_equal(true, !!e.http_body)
          assert_equal(true, e.json_body.kind_of?(Hash))
        end
      end

      should "a 401 should give an AuthenticationError with http status, body, and JSON body" do
        response = test_response(test_missing_id_error, 401)
        @mock.expects(:get).once.raises(RestClient::ExceptionWithResponse.new(response, 404))
        begin
          Nurego::Customer.retrieve("foo")
        rescue Nurego::AuthenticationError => e
          assert_equal(401, e.http_status)
          assert_equal(true, !!e.http_body)
          assert_equal(true, e.json_body.kind_of?(Hash))
        end
      end

      should "a 402 should give a CardError with http status, body, and JSON body" do
        response = test_response(test_missing_id_error, 402)
        @mock.expects(:get).once.raises(RestClient::ExceptionWithResponse.new(response, 404))
        begin
          Nurego::Customer.retrieve("foo")
        rescue Nurego::CardError => e
          assert_equal(402, e.http_status)
          assert_equal(true, !!e.http_body)
          assert_equal(true, e.json_body.kind_of?(Hash))
        end
      end

      should "a 404 should give an InvalidRequestError with http status, body, and JSON body" do
        response = test_response(test_missing_id_error, 404)
        @mock.expects(:get).once.raises(RestClient::ExceptionWithResponse.new(response, 404))
        begin
          Nurego::Customer.retrieve("foo")
        rescue Nurego::InvalidRequestError => e
          assert_equal(404, e.http_status)
          assert_equal(true, !!e.http_body)
          assert_equal(true, e.json_body.kind_of?(Hash))
        end
      end

      should "setting a nil value for a param should exclude that param from the request" do
        @mock.expects(:get).with do |url, api_key, params|
          uri = URI(url)
          query = CGI.parse(uri.query)
          (url =~ %r{^#{Nurego.api_base}/v1/charges?} &&
           query.keys.sort == ['offset', 'sad'])
        end.returns(test_response({ :count => 1, :data => [test_charge] }))
        Nurego::Charge.all(:count => nil, :offset => 5, :sad => false)

        @mock.expects(:post).with do |url, api_key, params|
          url == "#{Nurego.api_base}/v1/charges" &&
            api_key.nil? &&
            CGI.parse(params) == { 'amount' => ['50'], 'currency' => ['usd'] }
        end.returns(test_response({ :count => 1, :data => [test_charge] }))
        Nurego::Charge.create(:amount => 50, :currency => 'usd', :card => { :number => nil })
      end

      should "requesting with a unicode ID should result in a request" do
        response = test_response(test_missing_id_error, 404)
        @mock.expects(:get).once.with("#{Nurego.api_base}/v1/customers/%E2%98%83", nil, nil).raises(RestClient::ExceptionWithResponse.new(response, 404))
        c = Nurego::Customer.new("☃")
        assert_raises(Nurego::InvalidRequestError) { c.refresh }
      end

      should "requesting with no ID should result in an InvalidRequestError with no request" do
        c = Nurego::Customer.new
        assert_raises(Nurego::InvalidRequestError) { c.refresh }
      end

      should "making a GET request with parameters should have a query string and no body" do
        params = { :limit => 1 }
        @mock.expects(:get).once.with("#{Nurego.api_base}/v1/charges?limit=1", nil, nil).returns(test_response([test_charge]))
        Nurego::Charge.all(params)
      end

      should "making a POST request with parameters should have a body and no query string" do
        params = { :amount => 100, :currency => 'usd', :card => 'sc_token' }
        @mock.expects(:post).once.with do |url, get, post|
          get.nil? && CGI.parse(post) == {'amount' => ['100'], 'currency' => ['usd'], 'card' => ['sc_token']}
        end.returns(test_response(test_charge))
        Nurego::Charge.create(params)
      end

      should "loading an object should issue a GET request" do
        @mock.expects(:get).once.returns(test_response(test_customer))
        c = Nurego::Customer.new("test_customer")
        c.refresh
      end

      should "using array accessors should be the same as the method interface" do
        @mock.expects(:get).once.returns(test_response(test_customer))
        c = Nurego::Customer.new("test_customer")
        c.refresh
        assert_equal c.created, c[:created]
        assert_equal c.created, c['created']
        c['created'] = 12345
        assert_equal c.created, 12345
      end

      should "accessing a property other than id or parent on an unfetched object should fetch it" do
        @mock.expects(:get).once.returns(test_response(test_customer))
        c = Nurego::Customer.new("test_customer")
        c.charges
      end

      should "updating an object should issue a POST request with only the changed properties" do
        @mock.expects(:post).with do |url, api_key, params|
          url == "#{Nurego.api_base}/v1/customers/c_test_customer" && api_key.nil? && CGI.parse(params) == {'description' => ['another_mn']}
        end.once.returns(test_response(test_customer))
        c = Nurego::Customer.construct_from(test_customer)
        c.description = "another_mn"
        c.save
      end

      should "updating should merge in returned properties" do
        @mock.expects(:post).once.returns(test_response(test_customer))
        c = Nurego::Customer.new("c_test_customer")
        c.description = "another_mn"
        c.save
        assert_equal false, c.livemode
      end

      should "deleting should send no props and result in an object that has no props other deleted" do
        @mock.expects(:get).never
        @mock.expects(:post).never
        @mock.expects(:delete).with("#{Nurego.api_base}/v1/customers/c_test_customer", nil, nil).once.returns(test_response({ "id" => "test_customer", "deleted" => true }))

        c = Nurego::Customer.construct_from(test_customer)
        c.delete
        assert_equal true, c.deleted

        assert_raises NoMethodError do
          c.livemode
        end
      end

      should "loading an object with properties that have specific types should instantiate those classes" do
        @mock.expects(:get).once.returns(test_response(test_charge))
        c = Nurego::Charge.retrieve("test_charge")
        assert c.card.kind_of?(Nurego::NuregoObject) && c.card.object == 'card'
      end

      should "loading all of an APIResource should return an array of recursively instantiated objects" do
        @mock.expects(:get).once.returns(test_response(test_charge_array))
        c = Nurego::Charge.all.data
        assert c.kind_of? Array
        assert c[0].kind_of? Nurego::Charge
        assert c[0].card.kind_of?(Nurego::NuregoObject) && c[0].card.object == 'card'
      end

      context "error checking" do

        should "404s should raise an InvalidRequestError" do
          response = test_response(test_missing_id_error, 404)
          @mock.expects(:get).once.raises(RestClient::ExceptionWithResponse.new(response, 404))

          rescued = false
          begin
            Nurego::Customer.new("test_customer").refresh
            assert false #shouldn't get here either
          rescue Nurego::InvalidRequestError => e # we don't use assert_raises because we want to examine e
            rescued = true
            assert e.kind_of? Nurego::InvalidRequestError
            assert_equal "id", e.param
            assert_equal "Missing id", e.message
          end

          assert_equal true, rescued
        end

        should "5XXs should raise an APIError" do
          response = test_response(test_api_error, 500)
          @mock.expects(:get).once.raises(RestClient::ExceptionWithResponse.new(response, 500))

          rescued = false
          begin
            Nurego::Customer.new("test_customer").refresh
            assert false #shouldn't get here either
          rescue Nurego::APIError => e # we don't use assert_raises because we want to examine e
            rescued = true
            assert e.kind_of? Nurego::APIError
          end

          assert_equal true, rescued
        end

      end
    end
  end
end
