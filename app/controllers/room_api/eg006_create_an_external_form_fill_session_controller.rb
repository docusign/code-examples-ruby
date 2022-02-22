class RoomApi::Eg006CreateAnExternalFormFillSessionController < EgController
  before_action :check_auth

  def create
    args = {
      form_id: params['formId'],
      room_id: params['roomId'],
      account_id: session[:ds_account_id],
      base_path: session[:ds_base_path],
      access_token: session[:ds_access_token]
    }

    results = RoomApi::Eg006CreateAnExternalFormFillSessionService.new(args).worker

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
end
