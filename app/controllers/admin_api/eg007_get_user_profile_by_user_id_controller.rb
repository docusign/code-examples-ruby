class AdminApi::Eg007GetUserProfileByUserIdController < EgController
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
        user_id: param_gsub(params['user_id'])
      }

      results = AdminApi::Eg007GetUserProfileByUserIdService.new(args).worker

      @title = 'Retrieve the user’s DocuSign profile using a User ID'
      @h1 = 'Retrieve the user’s DocuSign profile using a User ID'
      @message = "Results from MultiProductUserManagement:getUserDSProfile method:"
      @json = results.to_json.to_json
      render 'ds_common/example_done'
    rescue DocuSign_Admin::ApiError => e
      handle_error(e)
    end
  end
end
