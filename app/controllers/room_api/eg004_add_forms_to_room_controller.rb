class RoomApi::Eg004AddFormsToRoomController < EgController
  before_action :check_auth
  before_action -> { @example = Utils::ManifestUtils.new.get_example(@manifest, 4) }

  def create
    args = {
      form_id: params['formId'],
      room_id: params['roomId'],
      account_id: session[:ds_account_id],
      base_path: session[:ds_base_path],
      access_token: session[:ds_access_token]
    }

    results = RoomApi::Eg004AddFormsToRoomService.new(args).worker

    @title = @example['ExampleName']
    @message = @example['ResultsPageText']
    @json = results.to_json.to_json

    render 'ds_common/example_done'
  end

  def get
    @rooms = RoomApi::GetDataService.new(session).get_rooms
    @form_libraries = RoomApi::GetDataService.new(session).get_form_libraries
  end
end
