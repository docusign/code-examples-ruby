class AdminApi::Aeg013CreateAccountController < EgController
  before_action -> { check_auth('Admin') }
  before_action -> { @example = Utils::ManifestUtils.new.get_example(@manifest, 13, 'Admin') }

  def create
    args = {
      access_token: session['ds_access_token'],
      organization_id: session['organization_id'],
      subscription_id: session['subscription_id'],
      plan_id: session['plan_id'],
      email: param_gsub(params['email']),
      first_name: param_gsub(params['first_name']),
      last_name: param_gsub(params['last_name'])
    }

    results = AdminApi::Eg013CreateAccountService.new(args).worker

    @title = @example['ExampleName']
    @message = @example['ResultsPageText']
    @json = results.to_json.to_json
    render 'ds_common/example_done'
  rescue DocuSign_Admin::ApiError => e
    handle_error(e)
  end

  def get
    super
    session[:organization_id] = AdminApi::GetDataService.new(session).get_organization_id if session[:organization_id].nil?
    args = {
      access_token: session['ds_access_token'],
      organization_id: session['organization_id']
    }
    plan_items = AdminApi::Eg013CreateAccountService.new(args).get_organization_plan_items
    print plan_items
    session['subscription_id'] = plan_items[0].subscription_id
    session['plan_id'] = plan_items[0].plan_id
  end
end
