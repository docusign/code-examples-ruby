class RoomApi::Eg005GetRoomsWithFiltersController < EgController
  before_action :check_auth

  def create
    args = {
      date_from: params[:date_from],
      date_to: params[:date_to],
      account_id: session[:ds_account_id],
      base_path: session[:ds_base_path],
      access_token: session[:ds_access_token]
    }

    results = RoomApi::Eg005GetRoomsWithFiltersService.new(args).worker

    @title = "The rooms with filters were loaded"
    @h1 = "The rooms with filters were loaded"
    @message = "Results from the Rooms: GetRooms method:"
    @json = results.to_json.to_json

    render 'ds_common/example_done'
  end

  def get
    @rooms = RoomApi::GetDataService.new(session).get_rooms
  end
end
