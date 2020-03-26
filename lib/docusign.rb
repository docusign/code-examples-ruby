# frozen_string_literal: true

require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class Docusign < OmniAuth::Strategies::OAuth2
      option :name, 'docusign'

      def client
        options.client_options.authorize_url = "#{options.oauth_base_uri}/oauth/auth"
        options.client_options.user_info_url = "#{options.oauth_base_uri}/oauth/userinfo"
        options.client_options.token_url = "#{options.oauth_base_uri}/oauth/token"
        unless options.allow_silent_authentication
          options.authorize_params.prompt = options.prompt
        end

        super
      end

      uid { raw_info['sub'] }

      info do
        {
          name: raw_info['name'],
          email: raw_info['email'],
          first_name: raw_info['given_name'],
          last_name: raw_info['family_name']
        }
      end

      extra do
        {
          sub: raw_info['sub'],
          account_id: @account['account_id'],
          account_name: @account['account_name'],
          base_uri: "#{@account['base_uri']}/restapi"
        }
      end

      private

      def raw_info
        @raw_info = access_token.get(options.client_options.user_info_url.to_s).parsed || {}
        fetch_account @raw_info['accounts'] unless @raw_info.nil?
        @raw_info
      end

      private

      def fetch_account(items)
        if options.target_account_id
          @account = items.select { |item| item[:account_id] == options.target_account_id }.first
        else
          @account = items.select { |item| item['is_default'] == true }.first
        end

        if @account.empty?
          raise 'Could not find account information for the user'
        end
      end
    end
  end
end
