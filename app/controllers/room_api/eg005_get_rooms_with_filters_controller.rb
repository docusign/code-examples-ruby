class RoomApi::Eg005GetRoomsWithFiltersController < EgController
  before_action :check_auth
  before_action -> { @example = Utils::ManifestUtils.new.get_example(@manifest, 5) }

  def create
    args = {
      date_from: params[:date_from],
      date_to: params[:date_to],
      account_id: session[:ds_account_id],
      base_path: session[:ds_base_path],
      access_token: session[:ds_access_token]
    }

    results = RoomApi::Eg005GetRoomsWithFiltersService.new(args).worker

    @title = @example['ExampleName']
    @message = @example['ResultsPageText']
    @json = results.to_json.to_json

    render 'ds_common/example_done'
  end

  def get
    @rooms = RoomApi::GetDataService.new(session).get_rooms
  end
end
