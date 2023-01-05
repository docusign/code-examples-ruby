class Clickwrap::Ceg003CreateNewClickwrapVersionController < EgController
  before_action -> { check_auth('Click') }
  before_action -> { @example = Utils::ManifestUtils.new.get_example(@manifest, 3, 'Click') }

  def create
    args = {
      account_id: session[:ds_account_id],
      base_path: session[:ds_base_path],
      access_token: session[:ds_access_token],
      clickwrap_id: session[:clickwrap_id],
      clickwrap_name: session[:clickwrap_name]
    }

    results = Clickwrap::Eg003CreateNewClickwrapVersionService.new(args).worker
    puts results.to_json.to_json
    @title = @example['ExampleName']
    @message = format_string(@example['ResultsPageText'], results.version_number, results.clickwrap_name)
    render 'ds_common/example_done'
  end
end
