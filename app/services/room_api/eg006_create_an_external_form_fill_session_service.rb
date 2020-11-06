# frozen_string_literal: true

class RoomApi::Eg006CreateAnExternalFormFillSessionService
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
    configuration.host = Rails.configuration.rooms_host

    api_client = DocuSign_Rooms::ApiClient.new(configuration)
    api_client.set_default_header("Authorization", "Bearer #{args[:access_token]}")

    rooms_api = DocuSign_Rooms::ExternalFormFillSessionsApi.new(api_client)

    begin
      rooms_api.create_external_form_fill_session(args[:account_id], body)
    rescue Exception => e
      return
    end
  end

  def body
    DocuSign_Rooms::ExternalFormFillSessionForCreate.new({
       formId: args[:form_id],
       roomId: args[:room_id]
    })
  end
end