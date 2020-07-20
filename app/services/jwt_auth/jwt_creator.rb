require 'yaml'

module JwtAuth
  class JwtCreator
    attr_reader :args, :session, :api_client

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
      @now = Time.now.to_f # seconds since epoch
      # Check that the token should be good
      if @token == nil or ((@now + TOKEN_REPLACEMENT_IN_SECONDS) > @expireIn)
        if @token == nil
          puts "\nStarting up: fetching token"
        else
          puts "\nToken is about to expire: fetching token"
        end
        self.update_token
      end
    end

    protected

    def update_token
      resp = Hash.new
      begin
        rsa_pk = File.join(Rails.root, 'config', 'docusign_private_key.txt')
        @api_client.set_oauth_base_path(Rails.configuration.aud)
        token = @api_client.request_jwt_user_token(Rails.configuration.jwt_integration_key, Rails.configuration.impersonated_user_guid, rsa_pk)
      rescue => exception
        body = JSON.parse(exception.response_body)

        if body['error'] == "consent_required"
          consent_scopes = "signature%20impersonation"
          consent_url = "#{Rails.configuration.authorization_server}/oauth/auth?response_type=code&scope=#{consent_scopes}&client_id=#{Rails.configuration.jwt_integration_key}&redirect_uri=#{Rails.configuration.app_url}/auth/docusign/callback"
          resp["url"] = consent_url;
          return resp["url"]
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
    end 
    end

    private

    def get_account_info(access_token)
      response = @api_client.get_user_info(access_token)
      accounts = response.accounts
      session[:ds_user_name] = response.name
      target = Rails.configuration.target_account_id 

      if target != nil and target != false
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

