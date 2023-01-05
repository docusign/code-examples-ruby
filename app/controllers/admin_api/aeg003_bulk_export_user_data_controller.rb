class AdminApi::Aeg003BulkExportUserDataController < EgController
  before_action -> { check_auth('Admin') }
  before_action -> { @example = Utils::ManifestUtils.new.get_example(@manifest, 3, 'Admin') }

  def create
    session[:organization_id] = AdminApi::GetDataService.new(session).get_organization_id if session[:organization_id].nil?

    file_path = File.expand_path(File.join(File.dirname(__FILE__), '../../../data/exportedUserData.csv'))

    begin
      request_body = {
        type: 'organization_memberships_export'
      }
      args = {
        account_id: session['ds_account_id'],
        base_path: session['ds_base_path'],
        access_token: session['ds_access_token'],
        organization_id: session['organization_id'],
        file_path: file_path,
        request_body: request_body
      }

      results = AdminApi::Eg003BulkExportUserDataService.new(args).worker

      @title = @example['ExampleName']
      @message = format_string(@example['ResultsPageText'], file_path)
      @json = results.to_json.to_json
      render 'ds_common/example_done'
    rescue DocuSign_Admin::ApiError => e
      handle_error(e)
    end
  end
end
