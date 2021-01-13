class Clickwrap::Eg003CreateNewClickwrapVersionController < EgController
  before_action :check_auth

  def create
    results = Clickwrap::Eg003CreateNewClickwrapVersionService.new(session).call
    puts results.to_json.to_json
    @title = 'Creating a new clickwrap version'
    @h1 = 'Creating a new clickwrap version'
    @message = "Version #{results.version_number} of clickwrap #{results.clickwrap_name} has been created"
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
