require 'yaml'

module JwtAuth
  class JwtCreator
    attr_reader :session, :api_client

    # DocuSign authorization URI to obtain individual consent
    # https://developers.docusign.com/platform/auth/jwt/jwt-get-token
    # https://developers.docusign.com/platform/auth/consent/obtaining-individual-consent/
    # https://developers.docusign.com/esign-rest-api/guides/authentication/obtaining-consent#individual-consent
    def self.consent_url
      base_uri = "#{Rails.configuration.authorization_server}/oauth/auth"
      response_type = "code"
      scopes = ERB::Util.url_encode("signature impersonation") # https://developers.docusign.com/platform/auth/reference/scopes/
      client_id = Rails.configuration.jwt_integration_key
      redirect_uri = "#{Rails.configuration.app_url}/auth/docusign/callback"
      consent_url = "#{base_uri}?response_type=#{response_type}&scope=#{scopes}&client_id=#{client_id}&redirect_uri=#{redirect_uri}"
      Rails.logger.info "==> Obtain Consent Grant required: #{consent_url}"
      consent_url
    end

    def initialize(session, client)
      @session = session
      @api_client = client
    end

    # @return [Boolean] `true` if the token was successfully updated, `false` if consent still needs to be grant'ed
    def check_jwt_token
      rsa_pk = docusign_rsa_private_key_file
      api_client.set_oauth_base_path(Rails.configuration.aud)
      begin
        token = api_client.request_jwt_user_token(Rails.configuration.jwt_integration_key, Rails.configuration.impersonated_user_guid, rsa_pk)
      rescue OpenSSL::PKey::RSAError => exception
        Rails.logger.error exception.inspect
        if File.read(rsa_pk).starts_with? '{RSA_PRIVATE_KEY}'
          fail "Please add your private RSA key to: #{rsa_pk}"
        else
          raise
        end
      rescue DocuSign_eSign::ApiError => exception
        Rails.logger.warn exception.inspect
        body = JSON.parse(exception.response_body)

        if body['error'] == "consent_required"
          false
        else
          details = <<~TXT
            See: https://support.docusign.com/articles/DocuSign-Developer-Support-FAQs#Troubleshoot-JWT-invalid_grant
            or https://developers.docusign.com/esign-rest-api/guides/authentication/oauth2-code-grant#troubleshooting-errors
            or try enabling `configuration.debugging = true` in DsCommonController#ds_must_authenticate for more logging output
          TXT
          fail "JWT response error: `#{body}`. #{details}"
        end
      else
        update_account_info(token)
        true
      end
    end

    private

    def update_account_info(token)
      account = get_account_info(token.access_token)
      api_client.config.host = account.base_uri
      session[:ds_access_token] = token.access_token
      session[:ds_account_id] = account.account_id
      session[:ds_base_path] = account.base_uri
      session[:ds_account_name] = account.account_name
      session[:ds_expires_at] = token.expires_in.to_i.seconds.from_now.to_i
      Rails.logger.info "==> JWT: Received token for impersonated user which will expire in: #{token.expires_in.to_i.seconds / 1.hour} hour at: #{Time.at(token.expires_in.to_i.seconds.from_now)}"
    end

    def get_account_info(access_token)
      user_info_response = api_client.get_user_info(access_token)
      accounts = user_info_response.accounts
      session[:ds_user_name] = user_info_response.name
      target_account_id = Rails.configuration.target_account_id
      get_account(accounts, target_account_id)
    end

    def get_account(accounts, target_account_id)
      if target_account_id.present?
        return accounts.find { |acct| acct.account_id == target_account_id }
        raise "The user does not have access to account #{target_account_id}"
      else
        accounts.find(&:is_default)
      end
    end

    def docusign_rsa_private_key_file
      File.join(Rails.root, 'config', 'docusign_private_key.txt')
    end
  end
end
