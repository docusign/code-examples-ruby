class Clickwrap::Eg002ActivateClickwrapController < EgController
  before_action :check_auth

  def create
    results = Clickwrap::Eg002ActivateClickwrapService.new(session).call

    @title = 'Activating a new clickwrap'
    @h1 = 'Activating a new clickwrap'
    @message = "The clickwrap #{results.clickwrap_name} has been activated"
    render 'ds_common/example_done'
  end

  private

  def check_auth
    minimum_buffer_min = 10
    token_ok = check_token(minimum_buffer_min)
    unless token_ok
      flash[:messages] = 'Sorry, you need to re-authenticate.'
      redirect_to '/ds/mustAuthenticate'
    end
  end
end
