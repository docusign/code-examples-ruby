# frozen_string_literal: true

class RoomApi::Eg003ExportDataFromRoomService
  attr_reader :args

  def initialize(args)
    @args = args
  end

  def worker
    #ds-snippet-start:Rooms3Step2
    configuration = DocuSign_Rooms::Configuration.new
    configuration.host = Rails.configuration.rooms_host

    api_client = DocuSign_Rooms::ApiClient.new(configuration)
    api_client.set_default_header('Authorization', "Bearer #{args[:access_token]}")
    #ds-snippet-end:Rooms3Step2

    #ds-snippet-start:Rooms3Step3
    rooms_api = DocuSign_Rooms::RoomsApi.new(api_client)
    rooms_api.get_room_field_data(args[:room_id], args[:account_id])
    #ds-snippet-end:Rooms3Step3
  end
end
