require 'nurego'
require 'minitest/unit'
require 'stringio'

#monkeypatch request methods
module Nurego
  @mock_rest_client = nil

  def self.mock_rest_client=(mock_client)
    @mock_rest_client = mock_client
  end

  def self.execute_request(opts)
    get_params = (opts[:headers] || {})[:params]
    post_params = opts[:payload]
    case opts[:method]
    when :get then @mock_rest_client.get opts[:url], get_params, post_params
    when :post then @mock_rest_client.post opts[:url], get_params, post_params
    when :delete then @mock_rest_client.delete opts[:url], get_params, post_params
    end
  end
end

def test_response(body, code=200)
  # When an exception is raised, restclient clobbers method_missing.  Hence we
  # can't just use the stubs interface.
  body = MultiJson.dump(body) if !(body.kind_of? String)
  m = double
  m.instance_variable_set('@nurego_values', { :body => body, :code => code })
  def m.body; @nurego_values[:body]; end
  def m.code; @nurego_values[:code]; end
  m
end

def test_customer(params={})
  {
    :object => "customer",
    :id => "c_test_customer",
    :email => 'test@email.com'
  }.merge(params)
end

def test_customer_array
  (0..5).collect { test_customer }
end

#FIXME nested overrides would be better than hardcoding plan_id
def test_subscription(plan_id="gold")
  {
    :current_period_end => 1308681468,
    :status => "trialing",
    :plan => {
      :interval => "month",
      :amount => 7500,
      :trial_period_days => 30,
      :object => "plan",
      :identifier => plan_id
    },
    :current_period_start => 1308595038,
    :start => 1308595038,
    :object => "subscription",
    :trial_start => 1308595038,
    :trial_end => 1308681468,
    :customer => "c_test_customer"
  }
end

def test_invalid_api_key_error
  {
    "error" => {
      "type" => "invalid_request_error",
      "message" => "Invalid API Key provided: invalid"
    }
  }
end

def test_missing_id_error
  {
    :error => {
      :param => "id",
      :type => "invalid_request_error",
      :message => "Missing id"
    }
  }
end

def test_api_error
  {
    :error => {
      :type => "api_error"
    }
  }
end

