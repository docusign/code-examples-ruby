class Clickwrap::Eg004ListClickwrapsController < EgController
  before_action :check_auth

  def create
    results = Clickwrap::Eg004ListClickwrapsService.new(session, request).call

    @title = 'List clickwraps results'
    @h1 = 'List clickwraps results'
    @message = "Results from the ClickWraps::getClickwraps method:"
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
