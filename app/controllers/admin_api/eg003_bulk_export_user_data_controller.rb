class AdminApi::Eg003BulkExportUserDataController < EgController
  before_action :check_auth

  def create
    if session[:organization_id].nil?
      session[:organization_id] = AdminApi::GetDataService.new(session).get_organization_id
    end

    file_path = File.expand_path(File.join(File.dirname(__FILE__), '../../../data/exportedUserData.csv'))

    begin
      results = AdminApi::Eg003BulkExportUserDataService.new(session, request, file_path).call

      @title = 'Bulk-export user data'
      @h1 = 'Bulk-export user data'
      @message = "User data exported to #{file_path}. </br> Results from UserExport::getUserListExport method:"
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
      redirect_to '/ds/mustAuthenticate'
    end
  end
end
