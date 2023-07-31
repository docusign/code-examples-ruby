# frozen_string_literal: true

class RoomApi::Eg004AddFormsToRoomService
  attr_reader :args

  def initialize(args)
    @args = args
  end

  def worker
    #ds-snippet-start:Rooms4Step2
    configuration = DocuSign_Rooms::Configuration.new
    configuration.host = Rails.configuration.rooms_host

    api_client = DocuSign_Rooms::ApiClient.new(configuration)
    api_client.set_default_header('Authorization', "Bearer #{args[:access_token]}")
    #ds-snippet-end:Rooms4Step2

    #ds-snippet-start:Rooms4Step4
    rooms_api = DocuSign_Rooms::RoomsApi.new(api_client)

    rooms_api.add_form_to_room(args[:room_id], args[:account_id], body(args[:form_id]))
    #ds-snippet-end:Rooms4Step4
  end

  def body(form_id)
    #ds-snippet-start:Rooms4Step3
    DocuSign_Rooms::FormForAdd.new({
                                     formId: form_id
                                   })
    #ds-snippet-end:Rooms4Step3
  end
end
