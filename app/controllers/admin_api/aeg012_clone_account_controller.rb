class AdminApi::Aeg012CloneAccountController < EgController
  before_action -> { check_auth('Admin') }
  before_action -> { @example = Utils::ManifestUtils.new.get_example(@manifest, 12, 'Admin') }

  def create
    args = {
      access_token: session['ds_access_token'],
      organization_id: session['organization_id'],
      source_account_id: param_gsub(params['source_account_id']),
      target_account_name: param_gsub(params['target_account_name']),
      target_account_first_name: param_gsub(params['target_account_first_name']),
      target_account_last_name: param_gsub(params['target_account_last_name']),
      target_account_email: param_gsub(params['target_account_email'])
    }

    results = AdminApi::Eg012CloneAccountService.new(args).worker

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
    @accounts = AdminApi::Eg012CloneAccountService.new(args).get_account.asset_group_accounts
  end
end
