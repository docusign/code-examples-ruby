class RoomApi::Reg006CreateAnExternalFormFillSessionController < EgController
  before_action -> { check_auth('Rooms') }
  before_action -> { @example = Utils::ManifestUtils.new.get_example(@manifest, 6, 'Rooms') }

  def create
    args = {
      form_id: params['formId'],
      room_id: params['roomId'],
      account_id: session[:ds_account_id],
      base_path: session[:ds_base_path],
      access_token: session[:ds_access_token],
      allowed_host: request.host_with_port
    }
    begin
      results = RoomApi::Eg006CreateAnExternalFormFillSessionService.new(args).worker

      @title = @example['ExampleName']
      @message = @example['ResultsPageText']
      @json = results.to_json
      @url = results.url

      render 'room_api/reg006_create_an_external_form_fill_session/results'
    rescue DocuSign_Rooms::ApiError => e
      handle_error(e)
    end
  end

  def get_rooms
    @rooms = RoomApi::GetDataService.new(session).get_rooms
  end

  def get_forms
    @form_libraries = RoomApi::GetDataService.new(session, params['roomId']).get_forms_from_room
  end
end
