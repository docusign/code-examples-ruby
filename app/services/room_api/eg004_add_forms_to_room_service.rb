# frozen_string_literal: true

class RoomApi::Eg004AddFormsToRoomService
  attr_reader :args

  def initialize(session, request)
    @args = {
        form_id: request.params['formId'],
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
    configuration.host = "https://demo.rooms.docusign.com/restapi"

    api_client = DocuSign_Rooms::ApiClient.new(configuration)
    api_client.set_default_header("Authorization", "Bearer #{args[:access_token]}")

    rooms_api = DocuSign_Rooms::RoomsApi.new(api_client)

    rooms_api.add_form_to_room(args[:room_id], args[:account_id], body)
  end

  def body
    DocuSign_Rooms::FormForAdd.new({
        formId: args[:form_id]
    })
  end
end