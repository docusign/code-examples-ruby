class AdminApi::Eg005AuditUsersController < EgController
    before_action :check_auth

    def create
      if session[:organization_id].nil?
        session[:organization_id] = AdminApi::GetDataService.new(session).get_organization_id
      end

      begin
        args = {
          account_id: session[:ds_account_id],
          organization_id: session['organization_id'],
          base_path: session[:ds_base_path],
          access_token: session[:ds_access_token]
        }

        results = AdminApi::Eg005AuditUsersService.new(args).worker

        @title = "Audit users"
        @h1 = "Audit users"
        @message = "Results from eSignUserManagement:getUserProfiles method:"
        @json = results.to_json.to_json

        render 'ds_common/example_done'
      rescue DocuSign_Admin::ApiError => e
        handle_error(e)
      end
    end
  end
