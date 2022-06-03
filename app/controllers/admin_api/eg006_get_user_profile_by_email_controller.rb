class AdminApi::Eg006GetUserProfileByEmailController < EgController
  include ApiCreator
  before_action :check_auth

  def create
    begin
      if session[:organization_id].nil?
        session[:organization_id] = AdminApi::GetDataService.new(session).get_organization_id
      end

      args = {
        access_token: session['ds_access_token'],
        organization_id: session['organization_id'],
        email: param_gsub(params['email'])
      }

      results = AdminApi::Eg006GetUserProfileByEmailService.new(args).worker

      @title = 'Retrieve the user’s DocuSign profile using an email address'
      @h1 = 'Retrieve the user’s DocuSign profile using an email address'
      @message = "Results from MultiProductUserManagement:getUserDSProfilesByEmail method:"
      @json = results.to_json.to_json
      render 'ds_common/example_done'
    rescue DocuSign_Admin::ApiError => e
      handle_error(e)
    end
  end
end
