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
      puts "\n\n getting org_id \n\n"
      accounts_api = DocuSign_Admin::AccountsApi.new(@api_client)
      accounts_api.get_organizations().organizations[0].as_json['id']
    end

    private

    def worker
      configuration = DocuSign_Admin::Configuration.new
      configuration.host = Rails.configuration.admin_host
      @api_client = DocuSign_Admin::ApiClient.new(configuration)
      @api_client.set_default_header("Authorization", "Bearer #{args[:access_token]}")
    end
  end