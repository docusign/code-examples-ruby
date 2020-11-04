# frozen_string_literal: true

class RoomApi::Eg005GetRoomsWithFiltersService
  attr :args

  def initialize(session, request)
    @args = {
        date_from: request.params[:date_from],
        date_to: request.params[:date_to],
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

    filters = DocuSign_Rooms::GetRoomsOptions.new
    filters.field_data_changed_start_date = args[:date_from]
    filters.field_data_changed_end_date = args[:date_to]

    rooms_api = DocuSign_Rooms::RoomsApi.new(api_client)
    response = rooms_api.get_rooms(args[:account_id], filters)
  end
end
