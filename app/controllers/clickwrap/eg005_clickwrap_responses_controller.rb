class Clickwrap::Eg005ClickwrapResponsesController < EgController
  before_action :check_auth

  def create
    results = Clickwrap::Eg005ClickwrapResponsesService.new(session, request).call

    @title = 'Getting clickwrap responses'
    @h1 = 'Getting clickwrap responses'
    @message = "Results from the ClickWraps::getClickwrapAgreements method:"
    @json = results.to_json.to_json
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
