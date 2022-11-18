class Clickwrap::Eg002ActivateClickwrapController < EgController
  before_action :check_auth
  before_action -> { @example = Utils::ManifestUtils.new.get_example(@manifest, 2) }

  def create
    args = {
      account_id: session[:ds_account_id],
      base_path: session[:ds_base_path],
      access_token: session[:ds_access_token],
      clickwrap_id: params[:clickwrapId]
    }

    Clickwrap::Eg002ActivateClickwrapService.new(args).worker

    @title = @example['ExampleName']
    @message = @example['ResultsPageText']
    render 'ds_common/example_done'
  end

  def get
    @clickwraps = Clickwrap::Eg002ActivateClickwrapService.new(session).get_inactive_clickwraps
  end
end
