class Clickwrap::Eg002ActivateClickwrapController < EgController
  before_action :check_auth

  def create
    args = {
      account_id: session[:ds_account_id],
      base_path: session[:ds_base_path],
      access_token: session[:ds_access_token],
      clickwrap_id: session[:clickwrap_id]
    }

    results = Clickwrap::Eg002ActivateClickwrapService.new(args).worker

    @title = 'Activate a new clickwrap'
    @h1 = 'Activate a new clickwrap'
    @message = "The clickwrap #{results.clickwrap_name} has been activated."
    render 'ds_common/example_done'
  end
end
