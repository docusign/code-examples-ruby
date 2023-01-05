class AdminApi::Aeg007GetUserProfileByUserIdController < EgController
  include ApiCreator
  before_action -> { check_auth('Admin') }
  before_action -> { @example = Utils::ManifestUtils.new.get_example(@manifest, 7, 'Admin') }

  def create
    session[:organization_id] = AdminApi::GetDataService.new(session).get_organization_id if session[:organization_id].nil?

    args = {
      access_token: session['ds_access_token'],
      organization_id: session['organization_id'],
      user_id: param_gsub(params['user_id'])
    }

    results = AdminApi::Eg007GetUserProfileByUserIdService.new(args).worker

    @title = @example['ExampleName']
    @message = @example['ResultsPageText']
    @json = results.to_json.to_json
    render 'ds_common/example_done'
  rescue DocuSign_Admin::ApiError => e
    handle_error(e)
  end
end
