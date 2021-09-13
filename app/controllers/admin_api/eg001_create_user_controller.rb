class AdminApi::Eg001CreateUserController < EgController
  include ApiCreator
  before_action :check_auth

  def create
    begin
      results = AdminApi::Eg001CreateUserService.new(session, request).call

      @title = 'Create a new active eSignature user'
      @h1 = 'Create a new active eSignature user'
      @message = "Results from eSignUserManagement:createUser method:"
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
    args = {
      account_id: session['ds_account_id'],
      base_path: session['ds_base_path'],
      access_token: session['ds_access_token']
    }

    accounts_api = create_account_api(args)
    @permission_profiles = accounts_api.list_permissions(args[:account_id]).permission_profiles

    groups_api = create_group_api(args)
    @groups = groups_api.list_groups(args[:account_id]).groups
  end

  private

  def check_auth
    minimum_buffer_min = 10
    token_ok = check_token(minimum_buffer_min)
    unless token_ok
      flash[:messages] = 'Sorry, you need to re-authenticate.'
      redirect_to '/ds/mustAuthenticate'
    end
  end
end
