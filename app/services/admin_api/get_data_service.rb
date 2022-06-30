class AdminApi::GetDataService
    attr_reader :args

    def initialize(session, options = {})
      @args = {
          account_id: session[:ds_account_id],
          base_path: session[:ds_base_path],
          access_token: session[:ds_access_token],
          organization_id: session[:organization_id]
      }
    end

    def get_product_permission_profiles
      worker

      # Step 3 start
      product_permission_profiles_api = DocuSign_Admin::ProductPermissionProfilesApi.new(@api_client)
      product_permission_profiles = product_permission_profiles_api.get_product_permission_profiles(args[:organization_id], args[:account_id])
      product_permission_profiles.as_json['product_permission_profiles']
      # Step 3 end
    end

    def get_ds_groups
      worker

      # Step 4 start
      ds_groups_api = DocuSign_Admin::DSGroupsApi.new(@api_client)
      ds_groups = ds_groups_api.get_ds_groups(args[:organization_id], args[:account_id])
      ds_groups.as_json['ds_groups']
      # Step 4 end
    end

    def get_organization_id
      worker
      accounts_api = DocuSign_Admin::AccountsApi.new(@api_client)
      accounts_api.get_organizations().organizations[0].as_json['id']
    end

    def check_import_status(import_id)
      worker
      bulk_imports_api = DocuSign_Admin::BulkImportsApi.new(@api_client)
      # Step 4 start
      response = bulk_imports_api.get_bulk_user_import_request(args[:organization_id], import_id);
      # Step 4 end
      return response
    end

    def check_user_exists_by_email(email)
      worker
      users_api = DocuSign_Admin::UsersApi.new(@api_client)
      options = DocuSign_Admin::GetUsersOptions.new()
      options.email = email
      response = users_api.get_users(args[:organization_id], options)

      if response.users.length == 0 || response.users[0].user_status == "closed"
        return false
      end

      return true
    end

    private

    def worker
      configuration = DocuSign_Admin::Configuration.new
      configuration.host = Rails.configuration.admin_host
      @api_client = DocuSign_Admin::ApiClient.new(configuration)
      @api_client.set_default_header("Authorization", "Bearer #{args[:access_token]}")
    end
  end