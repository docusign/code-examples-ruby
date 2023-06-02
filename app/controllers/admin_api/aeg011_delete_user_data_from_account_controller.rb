class AdminApi::Aeg011DeleteUserDataFromAccountController < EgController
  before_action -> { check_auth('Admin') }
  before_action -> { @example = Utils::ManifestUtils.new.get_example(@manifest, 11, 'Admin') }

  def create
    args = {
      account_id: session['ds_account_id'],
      access_token: session['ds_access_token'],
      user_id: param_gsub(params['user_id'])
    }

    results = AdminApi::Eg011DeleteUserDataFromAccountService.new(args).worker

    @title = @example['ExampleName']
    @message = @example['ResultsPageText']
    @json = results.to_json.to_json
    render 'ds_common/example_done'
  rescue DocuSign_Admin::ApiError => e
    handle_error(e)
  end
end
