require 'yaml'

module JwtAuth
  class JwtCreator
    include ApiCreator

    attr_reader :session, :api_client, :state

    # Docusign authorization URI to obtain individual consent
    # https://developers.docusign.com/platform/auth/jwt/jwt-get-token
    # https://developers.docusign.com/platform/auth/consent/obtaining-individual-consent/
    def self.consent_url(state, api)
      # GET /oauth/auth
      # This endpoint is used to obtain consent and is the first step in several authentication flows.
      # https://developers.docusign.com/platform/auth/reference/obtain-consent
      scope = 'signature impersonation' if %w[eSignature Monitor].include?(api)
      scope = 'signature impersonation dtr.rooms.read dtr.rooms.write dtr.documents.read dtr.documents.write dtr.profile.read dtr.profile.write dtr.company.read dtr.company.write room_forms' if api == 'Rooms'
      scope = 'signature impersonation click.manage click.send' if api == 'Click'
      scope = 'signature impersonation organization_read group_read permission_read user_read user_write account_read domain_read identity_provider_read user_data_redact asset_group_account_read asset_group_account_clone_write asset_group_account_clone_read organization_sub_account_write organization_sub_account_read' if api == 'Admin'
      scope = 'signature webforms_read webforms_instance_read webforms_instance_write' if api == 'WebForms'
      scope = 'signature organization_read notary_read notary_write' if api == 'Notary'
      scope = 'signature adm_store_unified_repo_read' if api == 'ConnectedFields'

      base_uri = "#{Rails.configuration.authorization_server}/oauth/auth"
      response_type = 'code'
      scopes = ERB::Util.url_encode(scope) # https://developers.docusign.com/platform/auth/reference/scopes/
      client_id = Rails.configuration.jwt_integration_key
      redirect_uri = "#{Rails.configuration.app_url}/auth/docusign/callback"
      consent_url = "#{base_uri}?response_type=#{response_type}&scope=#{scopes}&client_id=#{client_id}&state=#{state}&redirect_uri=#{redirect_uri}"
      Rails.logger.info "==> Obtain Consent Grant required: #{consent_url}"
      consent_url
    end

    def initialize(session)
      @session = session
      scope = 'signature impersonation'
      @client_module = DocuSign_eSign
      if session[:api] == 'Rooms'
        scope = "#{scope} signature dtr.rooms.read dtr.rooms.write dtr.documents.read dtr.documents.write dtr.profile.read dtr.profile.write dtr.company.read dtr.company.write room_forms"
        @client_module = DocuSign_Rooms
      end
      if session[:api] == 'Click'
        scope = 'signature click.manage click.send'
        @client_module = DocuSign_Click
      end
      @client_module = DocuSign_Monitor if session[:api] == 'Monitor'
      if session[:api] == 'Admin'
        scope = 'signature organization_read group_read permission_read user_read user_write account_read domain_read identity_provider_read user_data_redact asset_group_account_read asset_group_account_clone_write asset_group_account_clone_read organization_sub_account_write organization_sub_account_read'
        @client_module = DocuSign_Admin
      end
      if session[:api] == 'WebForms'
        scope = 'signature webforms_read webforms_instance_read webforms_instance_write'
        @client_module = DocuSign_WebForms
      end
      if session[:api] == 'Notary'
        scope = 'signature organization_read notary_read notary_write'
        @client_module = DocuSign_eSign
      end
      if session[:api] == 'ConnectedFields'
        scope = 'signature adm_store_unified_repo_read'
        @client_module = DocuSign_eSign
      end

      @scope = scope
      @api_client = create_initial_api_client(host: Rails.configuration.aud, client_module: @client_module, debugging: false)
    end

    # @return [Boolean] `true` if the token was successfully updated, `false` if consent still needs to be grant'ed
    def check_jwt_token
      rsa_pk = docusign_rsa_private_key_file
      begin
        # docusign_esign: POST /oauth/token
        # This endpoint enables you to exchange an authorization code or JWT token for an access token.
        # https://developers.docusign.com/platform/auth/reference/obtain-access-token
        token = api_client.request_jwt_user_token(Rails.configuration.jwt_integration_key, Rails.configuration.impersonated_user_guid, rsa_pk, 3600, @scope)
      rescue OpenSSL::PKey::RSAError => e
        Rails.logger.error e.inspect
        raise "Please add your private RSA key to: #{rsa_pk}" if File.read(rsa_pk).starts_with? '{RSA_PRIVATE_KEY}'

        raise
      rescue @client_module::ApiError => e
        Rails.logger.warn e.inspect

        return false if e.response_body.nil?

        body = JSON.parse(e.response_body)

        if body['error'] == 'consent_required'
          false
        else
          details = <<~TXT
            See: https://support.docusign.com/articles/DocuSign-Developer-Support-FAQs#Troubleshoot-JWT-invalid_grant
            or https://developers.docusign.com/esign-rest-api/guides/authentication/oauth2-code-grant#troubleshooting-errors
            or try enabling `configuration.debugging = true` in the initialize method above for more logging output
          TXT
          raise "JWT response error: `#{body}`. #{details}"
        end
      else
        update_account_info(token)
        true
      end
    end

    private

    def update_account_info(token)
      # docusign_esign: GET /oauth/userinfo
      # This endpoint returns information on the caller, including their name, email, account, and organizational information.
      # The response includes the base_uri needed to interact with the Docusign APIs.
      # https://developers.docusign.com/platform/auth/reference/user-info
      user_info_response = api_client.get_user_info(token.access_token)
      accounts = user_info_response.accounts
      target_account_id = Rails.configuration.target_account_id
      account = get_account(accounts, target_account_id)
      store_data(token, user_info_response, account)

      api_client.config.host = account.base_uri
      Rails.logger.info "==> JWT: Received token for impersonated user which will expire in: #{token.expires_in.to_i.seconds / 1.hour} hour at: #{Time.at(token.expires_in.to_i.seconds.from_now)}"
    end

    def store_data(token, user_info, account)
      session[:ds_access_token] = token.access_token
      session[:ds_expires_at] = token.expires_in.to_i.seconds.from_now.to_i
      session[:ds_user_name] = user_info.name
      session[:ds_account_id] = account.account_id
      session[:ds_base_path] = account.base_uri
      session[:ds_account_name] = account.account_name
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
