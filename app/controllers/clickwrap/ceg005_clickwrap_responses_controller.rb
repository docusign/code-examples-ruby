class Clickwrap::Ceg005ClickwrapResponsesController < EgController
  before_action -> { check_auth('Click') }
  before_action -> { @example = Utils::ManifestUtils.new.get_example(@manifest, 5, 'Click') }

  def create
    args = {
      account_id: session[:ds_account_id],
      base_path: session[:ds_base_path],
      access_token: session[:ds_access_token],
      clickwrap_id: session[:clickwrap_id],
      client_user_id: request[:client_user_id]
    }

    results = Clickwrap::Eg005ClickwrapResponsesService.new(args).worker

    @title = @example['ExampleName']
    @message = @example['ResultsPageText']
    @json = results.to_json.to_json
    render 'ds_common/example_done'
  end
end
