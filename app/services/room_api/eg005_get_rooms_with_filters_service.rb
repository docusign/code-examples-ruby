# frozen_string_literal: true

class RoomApi::Eg005GetRoomsWithFiltersService
  attr_reader :args

  def initialize(args)
    @args = args
  end

  def worker
    configuration = DocuSign_Rooms::Configuration.new
    configuration.host = Rails.configuration.rooms_host

    #ds-snippet-start:Rooms5Step2
    api_client = DocuSign_Rooms::ApiClient.new(configuration)
    api_client.set_default_header('Authorization', "Bearer #{args[:access_token]}")
    #ds-snippet-end:Rooms5Step2

    #ds-snippet-start:Rooms5Step3
    filters = DocuSign_Rooms::GetRoomsOptions.new
    filters.field_data_changed_start_date = args[:date_from]
    filters.field_data_changed_end_date = args[:date_to]
    #ds-snippet-end:Rooms5Step3

    #ds-snippet-start:Rooms5Step4
    rooms_api = DocuSign_Rooms::RoomsApi.new(api_client)
    rooms_api.get_rooms(args[:account_id], filters)
    #ds-snippet-end:Rooms5Step4
  end
end
