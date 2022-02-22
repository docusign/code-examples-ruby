class Clickwrap::Eg003CreateNewClickwrapVersionController < EgController
  before_action :check_auth

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
    @title = 'Create a new clickwrap version'
    @h1 = 'Create a new clickwrap version'
    @message = "Version #{results.version_number} of clickwrap #{results.clickwrap_name} has been created."
    render 'ds_common/example_done'
  end
end
