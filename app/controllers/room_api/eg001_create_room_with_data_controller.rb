class RoomApi::Eg001CreateRoomWithDataController < EgController
  before_action :check_auth
  before_action -> { @example = Utils::ManifestUtils.new.get_example(@manifest, 1) }

  def create
    args = {
      room_name: params[:roomName],
      office_id: RoomApi::GetDataService.new(session).get_offices[0]['officeId'],
      role_id: RoomApi::GetDataService.new(session).get_roles[2]['roleId'],
      account_id: session[:ds_account_id],
      base_path: session[:ds_base_path],
      access_token: session[:ds_access_token]
    }

    results = RoomApi::Eg001CreateRoomWithDataService.new(args).worker

    @title = @example['ExampleName']
    @message = format_string(@example['ResultsPageText'], results.room_id, results.name)
    @json = results.to_json.to_json

    render 'ds_common/example_done'
  end
end
