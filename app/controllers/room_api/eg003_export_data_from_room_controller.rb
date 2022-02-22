class RoomApi::Eg003ExportDataFromRoomController < EgController
  before_action :check_auth

  def create
    args = {
      room_id: params['roomId'],
      account_id: session[:ds_account_id],
      base_path: session[:ds_base_path],
      access_token: session[:ds_access_token]
    }

    results = RoomApi::Eg003ExportDataFromRoomService.new(args).worker

    @title = "The room data was successfully exported"
    @h1 = "The room data was successfully exported"
    @message = "Results from the Rooms::GetRoomFieldData method:"
    @json = results.to_json.to_json

    render 'ds_common/example_done'
  end

  def get
    @rooms = RoomApi::GetDataService.new(session).get_rooms
  end
end
