class AdminApi::Aeg010DeleteUserDataFromOrganizationController < EgController
  before_action -> { check_auth('Admin') }
  before_action -> { @example = Utils::ManifestUtils.new.get_example(@manifest, 10, 'Admin') }

  def create
    session[:organization_id] = AdminApi::GetDataService.new(session).get_organization_id if session[:organization_id].nil?

    args = {
      access_token: session['ds_access_token'],
      email: param_gsub(params['email']),
      organization_id: session['organization_id']
    }

    results = AdminApi::Eg010DeleteUserDataFromOrganizationService.new(args).worker

    @title = @example['ExampleName']
    @message = @example['ResultsPageText']
    @json = results.to_json.to_json
    render 'ds_common/example_done'
  rescue DocuSign_Admin::ApiError => e
    handle_error(e)
  end
end
