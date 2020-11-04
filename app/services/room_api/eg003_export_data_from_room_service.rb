# frozen_string_literal: true

class RoomApi::Eg003ExportDataFromRoomService
  attr :args

  def initialize(session, request)
    @args = {
        room_id: request.params['roomId'],
        account_id: session[:ds_account_id],
        base_path: session[:ds_base_path],
        access_token: session[:ds_access_token]
    }
  end

  def call
    worker
  end

  private

  def worker
    configuration = DocuSign_Rooms::Configuration.new
    configuration.host = Rails.configuration.host

    api_client = DocuSign_Rooms::ApiClient.new(configuration)
    api_client.set_default_header("Authorization", "Bearer #{args[:access_token]}")

    rooms_api = DocuSign_Rooms::RoomsApi.new(api_client)
    response = rooms_api.get_room_field_data(args[:room_id],args[:account_id])
  end
end