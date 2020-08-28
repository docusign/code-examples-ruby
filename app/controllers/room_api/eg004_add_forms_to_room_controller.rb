class RoomApi::Eg004AddFormsToRoomController < EgController
  before_action :check_auth

  def create
    results = RoomApi::Eg004AddFormsToRoomService.new(session, request).call

    @scenarios_name = "eg004_add_forms_to_room"
    @result = results.to_json.to_json

    render 'room_api/return'
  end

  def get
    @rooms = RoomApi::GetDataService.new(session).get_rooms
    @form_libraries = RoomApi::GetDataService.new(session).get_form_libraries
  end

  private

  def check_auth
    minimum_buffer_min = 10
    token_ok = check_token(minimum_buffer_min)
    unless token_ok
      flash[:messages] = 'Sorry, you need to re-authenticate.'
      # We could store the parameters of the requested operation so it could be restarted automatically.
      # But since it should be rare to have a token issue here, we'll make the user re-enter the form data after authentication.
      redirect_to '/ds/mustAuthenticate'
    end
  end
end
