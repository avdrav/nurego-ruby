require 'uri'
require 'uri/http'
require 'uaa'

module Nurego
  module Auth

    @provider_site = 'https://uaa.nurego.com'
    @client_id = 'your client id'
    @client_secret = 'your client secret'

    @logger = nil

    class << self
      attr_accessor :provider_site, :client_id, :client_secret, :header_token, :logger

      def login(username, password)
        @header_token = fetch_header_token(username, password)
      end

      def logout
        @header_token = nil
      end

      def change_password(user_id, password, current_password)
        uaa_user_account.change_password(user_id, password, current_password)
      rescue CF::UAA::NotFound, CF::UAA::TargetError => e
        raise UserNotFoundError.new('User not found') # TODO better error message
      rescue CF::UAA::AuthError, CF::UAA::BadResponse => e
        raise AuthenticationError.new('OAuth authentication failed ' +
                                          'Make sure you set "Nurego.client_id = <client_id>". ' +
                                          'Please also make sure you set "Nurego.client_secret = <client secret>". ' +
                                          'See https://www.nurego.com/api for details, or email support@nurego.com ' +
                                          'if you have any questions.') if e.message == "status 401" || e.is_a?(CF::UAA::AuthError)
        raise NuregoError "fetch_access_info #{e.inspect}"
      end

      private
      def fetch_access_info(username, password)
        token = token_issuer.owner_password_grant(username, password)
        info = token.info
        {
            :access_token => info[:access_token],
            :refresh_token => info[:refresh_token],
            :token_type => info[:token_type],
            :expires_at => Time.now.to_i + info[:expires_in],
            :header_token => info[:token_type] + " " + info[:access_token]
        }
      rescue CF::UAA::BadResponse, CF::UAA::TargetError => e
        puts e.inspect
        raise AuthenticationError.new('OAuth authentication failed ' +
                                          'Make sure you set "Nurego.client_id = <client_id>". ' +
                                          'Please also make sure you set "Nurego.client_secret = <client secret>". ' +
                                          'See https://www.nurego.com/api for details, or email support@nurego.com ' +
                                          'if you have any questions.') if e.message == "status 401" || e.is_a?(CF::UAA::TargetError)
        raise NuregoError "fetch_access_info #{e.inspect}"
      end

      def fetch_admin_access_token
        token = token_issuer.client_credentials_grant
        info = token.info

        info[:token_type] + " " + info[:access_token]
      rescue CF::UAA::BadResponse => e
        #TODO check error message here
        raise AuthenticationError.new('OAuth authentication failed ' +
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

        {
            token: access_info[:header_token],
            expires_at: access_info[:expires_at]
        }
      end

      def admin_access_token
        @admin_access_token ||= fetch_admin_access_token
      end

      def build_uaa_user_account
        CF::UAA::Scim.new(@provider_site, admin_access_token).tap do |uaa_user_account|
          uaa_user_account.logger = @logger
        end
      end

      def build_token_issuer
        CF::UAA::TokenIssuer.new(@provider_site, @client_id, @client_secret, {symbolize_keys: true}).tap do |issuer|
          issuer.logger = @logger
        end
      end

      def token_issuer
        @token_issuer ||= build_token_issuer
      end

      def uaa_user_account
        @uaa_user_account ||= build_uaa_user_account
      end
    end
  end
end

