class Clickwrap::Eg004ListClickwrapsController < EgController
  before_action :check_auth

  def create
    args = {
      account_id: session[:ds_account_id],
      base_path: session[:ds_base_path],
      access_token: session[:ds_access_token]
    }

    results = Clickwrap::Eg004ListClickwrapsService.new(args).worker

    @title = 'Get a list of clickwraps'
    @h1 = 'Get a list of clickwraps'
    @message = "Results from the ClickWraps::getClickwraps method:"
    @json = results.to_json.to_json
    render 'ds_common/example_done'
  end
end
