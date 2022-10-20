# frozen_string_literal: true

class RoomApi::Eg006CreateAnExternalFormFillSessionService
  attr_reader :args

  def initialize(args)
    @args = args
  end

  def worker
    configuration = DocuSign_Rooms::Configuration.new
    configuration.host = Rails.configuration.rooms_host

    api_client = DocuSign_Rooms::ApiClient.new(configuration)
    api_client.set_default_header('Authorization', "Bearer #{args[:access_token]}")

    rooms_api = DocuSign_Rooms::ExternalFormFillSessionsApi.new(api_client)

    begin
      rooms_api.create_external_form_fill_session(args[:account_id], body(args))
    rescue Exception
      nil
    end
  end

  private

  def body(args)
    DocuSign_Rooms::ExternalFormFillSessionForCreate.new({
                                                           formId: args[:form_id],
                                                           roomId: args[:room_id]
                                                         })
  end
end
