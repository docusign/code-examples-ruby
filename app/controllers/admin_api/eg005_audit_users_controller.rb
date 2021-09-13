class AdminApi::Eg005AuditUsersController < EgController
    before_action :check_auth

    def create
      if session[:organization_id].nil?
        session[:organization_id] = AdminApi::GetDataService.new(session).get_organization_id
      end

      begin
        results = AdminApi::Eg005AuditUsersService.new(session, request).call

        @title = "Audit users"
        @h1 = "Audit users"
        @message = "Results from eSignUserManagement:getUserProfiles method:"
        @json = results.to_json.to_json

        render 'ds_common/example_done'
      rescue DocuSign_Admin::ApiError => e
        error = JSON.parse e.response_body
        @error_code = e.code
        @error_message = error['error_description']
        render 'ds_common/error'
      end
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
