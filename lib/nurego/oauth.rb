require 'uri'
require 'uri/http'
require 'uaa'

module Nurego
  module OAuth
    def fetch_access_info(username, password)
      token = token_issuer.owner_password_grant(username, password)
      info = token.info
      {
          :access_token => info['access_token'],
          :refresh_token => info['refresh_token'],
          :token_type => info['token_type'],
          :expires_at => Time.now.to_i + info['expires_in'],
          :header_token => info['token_type'] + " " + info['access_token']
      }
    rescue CF::UAA::BadResponse => e
      raise AuthenticationError.new('OAuth authentication failed' +
                                     'Make sure you set "Nurego.client_id = <client_id>". ' +
                                     'Please also make sure you set "Nurego.client_secret = <client secret>". ' +
                                     'See https://www.nurego.com/api for details, or email support@nurego.com ' +
                                     'if you have any questions.') if e.message == "status 401"
      raise NuregoError "fetch_access_info #{e.inspect}"
    end

    def fetch_access_token(username, password)
      fetch_access_info(username, password)[:access_token]
    end

    def fetch_header_token(username, password)
      access_info = fetch_access_info(username, password)
      { token: access_info[:header_token], expires_at: access_info[:expires_at] }
    end

    private

    def build_token_issuer
      CF::UAA::TokenIssuer.new(@provider_site, @client_id, @client_secret)
        .tap do |issuer|
          issuer.logger = @logger
      end
    end

    def token_issuer
      @token_issuer ||= build_token_issuer
    end
  end
end
