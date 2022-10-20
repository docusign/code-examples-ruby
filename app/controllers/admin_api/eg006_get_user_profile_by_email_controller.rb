class AdminApi::Eg006GetUserProfileByEmailController < EgController
  include ApiCreator
  before_action :check_auth
  before_action -> { @example = Utils::ManifestUtils.new.get_example(@manifest, 6) }

  def create
    session[:organization_id] = AdminApi::GetDataService.new(session).get_organization_id if session[:organization_id].nil?

    args = {
      access_token: session['ds_access_token'],
      organization_id: session['organization_id'],
      email: param_gsub(params['email'])
    }

    results = AdminApi::Eg006GetUserProfileByEmailService.new(args).worker

    @title = @example['ExampleName']
    @message = @example['ResultsPageText']
    @json = results.to_json.to_json
    render 'ds_common/example_done'
  rescue DocuSign_Admin::ApiError => e
    handle_error(e)
  end
end
