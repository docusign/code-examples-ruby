# frozen_string_literal: true

class AdminApi::Eg002CreateActiveClmEsignUserService
    attr_reader :args

    def initialize(session, request)
      @args = {
          user_name: request.params[:user_name],
          first_name: request.params[:first_name],
          last_name: request.params[:last_name],
          email: request.params[:email],
          clm_permission_profile_id:  request.params[:clm_permission_profile_id],
          esign_permission_profile_id:  request.params[:esign_permission_profile_id],
          clm_product_id: request.params[:clm_product_id],
          esign_product_id: request.params[:esign_product_id],
          ds_group_id:  request.params[:ds_group_id],
          account_id: session[:ds_account_id],
          organization_id: Rails.configuration.organization_id,
          base_path: session[:ds_base_path],
          access_token: session[:ds_access_token]
      }
    end

    def call
      worker
    end

    private

    def worker
      # Step 2 start
      configuration = DocuSign_Admin::Configuration.new
      configuration.host = Rails.configuration.admin_host

      api_client = DocuSign_Admin::ApiClient.new(configuration)
      api_client.set_default_header("Authorization", "Bearer #{args[:access_token]}")
      # Step 2 end

      # Step 6 start
      users_api = DocuSign_Admin::UsersApi.new(api_client)
      response = users_api.add_or_update_user(args[:organization_id], args[:account_id], body)
      # Step 6 end
    end

    # Step 5 start
    def body
      {
        user_name: args[:user_name],
        first_name: args[:first_name],
        last_name: args[:last_name],
        email: args[:email],
        auto_activate_memberships: true,
        product_permission_profiles: [
            {
                permission_profile_id: args[:esign_permission_profile_id],
                product_id: args[:esign_product_id]
            },
            {
                permission_profile_id: args[:clm_permission_profile_id],
                product_id: args[:clm_product_id]
            }
        ],
        ds_groups: [
            {
                ds_group_id: args[:ds_group_id]
            }
        ]
      }
  end
  # Step 5 end

end