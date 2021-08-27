class AdminApi::Eg002CreateActiveClmEsignUserController < EgController
    before_action :check_auth

    def create
      begin
        results = AdminApi::Eg002CreateActiveClmEsignUserService.new(session, request).call

        @title = "Create a new active user for CLM and eSignature"
        @h1 = "Create a new active user for CLM and eSignature"
        @message = "Results from MultiProductUserManagement::addOrUpdateUser method:"
        @json = results.to_json.to_json

        render 'ds_common/example_done'
      rescue DocuSign_Admin::ApiError => e
        error = JSON.parse e.response_body
        @error_code = e.code
        @error_message = error['error_description']
        render 'ds_common/error'
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

    private

    def check_auth
      minimum_buffer_min = 10
      token_ok = check_token(minimum_buffer_min)
      unless token_ok
        flash[:messages] = 'Sorry, you need to re-authenticate.'
        # We could store the parameters of the requested operation so it could be restarted automatically
        # But since it should be rare to have a token issue here, we'll make the user re-enter the form data after authentication
        redirect_to '/ds/mustAuthenticate'
      end
    end
  end
