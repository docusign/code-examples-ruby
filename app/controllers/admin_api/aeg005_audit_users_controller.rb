class AdminApi::Aeg005AuditUsersController < EgController
  before_action -> { check_auth('Admin') }
  before_action -> { @example = Utils::ManifestUtils.new.get_example(@manifest, 5, 'Admin') }

  def create
    session[:organization_id] = AdminApi::GetDataService.new(session).get_organization_id if session[:organization_id].nil?

    begin
      args = {
        account_id: session[:ds_account_id],
        organization_id: session['organization_id'],
        base_path: session[:ds_base_path],
        access_token: session[:ds_access_token]
      }

      results = AdminApi::Eg005AuditUsersService.new(args).worker

      @title = @example['ExampleName']
      @message = @example['ResultsPageText']
      @json = results.to_json.to_json

      render 'ds_common/example_done'
    rescue DocuSign_Admin::ApiError => e
      handle_error(e)
    end
  end
end
