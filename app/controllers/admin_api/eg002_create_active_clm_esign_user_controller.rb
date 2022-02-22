class AdminApi::Eg002CreateActiveClmEsignUserController < EgController
    before_action :check_auth

    def create
      begin
        args = {
          user_name: params[:user_name],
          first_name: params[:first_name],
          last_name: params[:last_name],
          email: params[:email],
          clm_permission_profile_id:  params[:clm_permission_profile_id],
          esign_permission_profile_id:  params[:esign_permission_profile_id],
          clm_product_id: params[:clm_product_id],
          esign_product_id: params[:esign_product_id],
          ds_group_id:  params[:ds_group_id],
          account_id: session[:ds_account_id],
          organization_id: session['organization_id'],
          base_path: session[:ds_base_path],
          access_token: session[:ds_access_token]
        }

        results = AdminApi::Eg002CreateActiveClmEsignUserService.new(args).worker

        @title = "Create a new active user for CLM and eSignature"
        @h1 = "Create a new active user for CLM and eSignature"
        @message = "Results from MultiProductUserManagement::addOrUpdateUser method:"
        @json = results.to_json.to_json

        render 'ds_common/example_done'
      rescue DocuSign_Admin::ApiError => e
        handle_error(e)
      end
    end

    def get
      super
      if session[:organization_id].nil?
        session[:organization_id] = AdminApi::GetDataService.new(session).get_organization_id
      end
      product_permission_profiles = AdminApi::GetDataService.new(session).get_product_permission_profiles

      product_permission_profiles.each do |product_permission_profile|
        if product_permission_profile['product_name'] == "CLM"
          @clm_permission_profiles = product_permission_profile['permission_profiles']
          @clm_product_id = product_permission_profile['product_id']
        else
          @esign_permission_profiles = product_permission_profile['permission_profiles']
          @esign_product_id = product_permission_profile['product_id']
        end
      end
      @ds_groups = AdminApi::GetDataService.new(session).get_ds_groups
    end
  end
