class RoomApi::Eg006CreateAnExternalFormFillSessionController < EgController
  before_action :check_auth

  def create
    results = RoomApi::Eg006CreateAnExternalFormFillSessionService.new(session, request).call

    @title = "External form fill session was successfully created"
    @h1 = "External form fill session was successfully created"
    @message = "To fill the form navigate the following URL: <a href='${externalForm.url}'>Fill the form</a>"
    @json = results.to_json.to_json

    render 'ds_common/example_done'
  end

  def get_rooms
    @rooms = RoomApi::GetDataService.new(session).get_rooms
  end

  def get_forms
    @form_libraries = RoomApi::GetDataService.new(session, params['roomId']).get_forms_from_room
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
