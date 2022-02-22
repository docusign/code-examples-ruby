class RoomApi::Eg001CreateRoomWithDataController < EgController
  before_action :check_auth

  def create
    args = {
      room_name:  params[:roomName],
      office_id:  RoomApi::GetDataService.new(session).get_offices[0]['officeId'],
      role_id:  RoomApi::GetDataService.new(session).get_roles[2]['roleId'],
      account_id: session[:ds_account_id],
      base_path: session[:ds_base_path],
      access_token: session[:ds_access_token]
    }

    results = RoomApi::Eg001CreateRoomWithDataService.new(args).worker

    @title = "The room was successfully created"
    @h1 = "The room was successfully created"
    @message = "The room was created! Room ID: #{results.room_id}, Name: #{results.name}"
    @json = results.to_json.to_json

    render 'ds_common/example_done'
  end
end
