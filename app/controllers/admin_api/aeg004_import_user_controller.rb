class AdminApi::Aeg004ImportUserController < EgController
  before_action -> { check_auth('Admin') }
  before_action -> { @example = Utils::ManifestUtils.new.get_example(@manifest, 4, 'Admin') }

  def create
    session[:organization_id] = AdminApi::GetDataService.new(session).get_organization_id if session[:organization_id].nil?

    file_path = File.expand_path(File.join(File.dirname(__FILE__), '../../../data/userData.csv'))

    begin
      args = {
        account_id: session['ds_account_id'],
        base_path: session['ds_base_path'],
        access_token: session['ds_access_token'],
        organization_id: session['organization_id'],
        csv_file_path: file_path
      }

      results = AdminApi::Eg004ImportUserService.new(args).worker
      session[:import_id] = results.id

      @title = @example['ExampleName']
      @check_status = true,
                      @message = @example['ResultsPageText']
      @json = results.to_json.to_json
      render 'ds_common/example_done'
    rescue DocuSign_Admin::ApiError => e
      handle_error(e)
    end
  end

  def check_status
    session[:organization_id] = AdminApi::GetDataService.new(session).get_organization_id if session[:organization_id].nil?

    begin
      import_id = session[:import_id]
      results = AdminApi::GetDataService.new(session).check_import_status(import_id)

      @status = results.status
      @title = @example['ExampleName']
      @message = @example['AdditionalPage'][0]['ResultsPageText']
      @json = results.to_json.to_json
      render 'admin_api/eg004_import_user/get_status.html.erb'
    rescue DocuSign_Admin::ApiError => e
      error = JSON.parse e.response_body
      @error_code = e.code
      @error_message = error['error_description']
      render 'ds_common/error'
    end
  end
end
