class Clickwrap::Eg005ClickwrapResponsesController < EgController
  before_action :check_auth

  def create
    args = {
      account_id: session[:ds_account_id],
      base_path: session[:ds_base_path],
      access_token: session[:ds_access_token],
      clickwrap_id: session[:clickwrap_id],
      client_user_id: request[:client_user_id]
    }

    results = Clickwrap::Eg005ClickwrapResponsesService.new(args).worker

    @title = 'Getting clickwrap responses'
    @h1 = 'Getting clickwrap responses'
    @message = "Results from the ClickWraps::getClickwrapAgreements method:"
    @json = results.to_json.to_json
    render 'ds_common/example_done'
  end
end
