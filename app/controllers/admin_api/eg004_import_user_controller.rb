class AdminApi::Eg004ImportUserController < EgController
  before_action :check_auth

  def create
    if session[:organization_id].nil?
      session[:organization_id] = AdminApi::GetDataService.new(session).get_organization_id
    end

    file_path = File.expand_path(File.join(File.dirname(__FILE__), '../../../data/userData.csv'))

    begin
      results = AdminApi::Eg004ImportUserService.new(session, request, file_path).call
      session[:import_id] = results.id

      @title = 'Add users via bulk import'
      @h1 = 'Add users via bulk import'
      @check_status=true,
      @message = "Results from UserImport::addBulkUserImport method:"
      @json = results.to_json.to_json
      render 'ds_common/example_done'
    rescue DocuSign_Admin::ApiError => e
      error = JSON.parse e.response_body
      @error_code = e.code
      @error_message = error['error_description']
      render 'ds_common/error'
    end
  end

  def check_status
    if session[:organization_id].nil?
      session[:organization_id] = AdminApi::GetDataService.new(session).get_organization_id
    end

    begin
      import_id = session[:import_id]
      results = AdminApi::GetDataService.new(session).check_import_status(import_id)

      @status = results.status
      @title = 'Add users via bulk import'
      @h1 = 'Add users via bulk import'
      @message = "Results from UserImport::getbulkuserimportrequest method:"
      @json = results.to_json.to_json
      render 'admin_api/eg004_import_user/get_status.html.erb'
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
      redirect_to '/ds/mustAuthenticate'
    end
  end
end
