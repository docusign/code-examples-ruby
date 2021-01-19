class RoomApi::Eg002CreateRoomWithTemplateController < EgController
  before_action :check_auth

  def create
    results = RoomApi::Eg002CreateRoomWithTemplateService.new(session, request).call

    @title = "The room was successfully created"
    @h1 = "The room was successfully created"
    @message = "The room was created! Room ID: #{results.room_id}, Name: #{results.name}"
    @json = results.to_json.to_json

    render 'ds_common/example_done'
  end

  def get
    @templates = RoomApi::GetDataService.new(session).get_templates
  end

  private

  def check_auth
    minimum_buffer_min = 10
    token_ok = check_token(minimum_buffer_min)
    unless token_ok
      flash[:messages] = 'Sorry, you need to re-authenticate.'
      # We could store the parameters of the requested operation so it could be restarted automatically
      # But since it should be rare to have a token issue here, we'll make the user re-enter the form data after authentication
      redirect_to '/ds/mustAuthenticate'
    end
  end
end
