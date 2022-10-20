# frozen_string_literal: true

class RoomApi::Eg004AddFormsToRoomService
  attr_reader :args

  def initialize(args)
    @args = args
  end

  def worker
    configuration = DocuSign_Rooms::Configuration.new
    configuration.host = Rails.configuration.rooms_host

    api_client = DocuSign_Rooms::ApiClient.new(configuration)
    api_client.set_default_header('Authorization', "Bearer #{args[:access_token]}")

    rooms_api = DocuSign_Rooms::RoomsApi.new(api_client)

    rooms_api.add_form_to_room(args[:room_id], args[:account_id], body(args[:form_id]))
  end

  def body(form_id)
    DocuSign_Rooms::FormForAdd.new({
                                     formId: form_id
                                   })
  end
end
