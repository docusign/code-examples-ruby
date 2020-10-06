require 'yaml'

module JwtAuth
  class JwtCreator
    attr_reader :session, :api_client, :token

    TOKEN_REPLACEMENT_IN_SECONDS = 10 * 60 # 10 minutes Application

    @account = nil
    @account_id = nil
    @token = nil
    @expireIn = 0
    @private_key = nil

    def initialize(session, client)
      @session = session
      @api_client = client
    end

    def check_jwt_token
      if expired?
        update_token
      end
    end

    private

    def expired?
      @now = Time.now.to_f # seconds since epoch
      # Check that the token should be good
      is_expired = token.nil? or ((@now + TOKEN_REPLACEMENT_IN_SECONDS) > @expireIn)
      if is_expired
        if token.nil?
          puts "\nJWT: Starting up: fetching token"
        else
          puts "\nJWT: Token is about to expire: fetching token"
        end
      end
      is_expired
    end

    def update_token
      resp = Hash.new
      begin
        rsa_pk = File.join(Rails.root, 'config', 'docusign_private_key.txt')
        @api_client.set_oauth_base_path(Rails.configuration.aud)
        token = @api_client.request_jwt_user_token(Rails.configuration.jwt_integration_key, Rails.configuration.impersonated_user_guid, rsa_pk)
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
          consent_scopes = "signature%20impersonation"
          consent_url = "#{Rails.configuration.authorization_server}/oauth/auth?response_type=code&scope=#{consent_scopes}&client_id=#{Rails.configuration.jwt_integration_key}&redirect_uri=#{Rails.configuration.app_url}/auth/docusign/callback"
          # https://developers.docusign.com/esign-rest-api/guides/authentication/obtaining-consent#individual-consent
          Rails.logger.info "Obtain Consent: #{consent_url}"
          resp["url"] = consent_url;
          return resp["url"]
        else
          details = <<~TXT
            See: https://support.docusign.com/articles/DocuSign-Developer-Support-FAQs#Troubleshoot-JWT-invalid_grant
            or https://developers.docusign.com/esign-rest-api/guides/authentication/oauth2-code-grant#troubleshooting-errors
            or try enabling `configuration.debugging = true` in DsCommonController#ds_must_authenticate for more logging output
          TXT
          fail "JWT response error: `#{body}`. #{details}"
        end
      else
        @account= get_account_info(token.access_token)
        @api_client.config.host = @account.base_uri
        @account_id = @account.account_id
        session[:ds_access_token] = token.access_token
        session[:ds_account_id] = @account_id
        session[:ds_base_path] = @account.base_uri
        session[:ds_account_name] = @account.account_name
        @expireIn = Time.now.to_f + token.expires_in.to_i
        session[:ds_expires_at] = @expireIn
        puts "Received token"
        resp["url"] = "#{Rails.configuration.app_url}";
        return resp["url"]
      end
    end

    def get_account_info(access_token)
      response = @api_client.get_user_info(access_token)
      accounts = response.accounts
      session[:ds_user_name] = response.name
      target = Rails.configuration.target_account_id

      if target.present?
        accounts.each do |acct|
          if acct.account_id == target
            return acct
          end
        end
        raise "The user does not have access to account #{target}"
      end

      accounts.each do |acct|
        if acct.is_default
          return acct
        end
      end
    end
  end
end
