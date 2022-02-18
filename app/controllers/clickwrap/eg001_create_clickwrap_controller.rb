class Clickwrap::Eg001CreateClickwrapController < EgController
  before_action :check_auth

  def create
    args = {
      account_id: session[:ds_account_id],
      base_path: session[:ds_base_path],
      access_token: session[:ds_access_token],
      clickwrap_name: request[:clickwrapName]
    }

    results = Clickwrap::Eg001CreateClickwrapService.new(args).worker

    session[:clickwrap_id] = results.clickwrap_id
    session[:clickwrap_name] = results.clickwrap_name

    @title = 'Creating a new clickwrap'
    @h1 = 'Creating a new clickwrap'
    @message = "The clickwrap #{results.clickwrap_name} has been created!"
    @json = results.to_json.to_json
    render 'ds_common/example_done'
  end
end
