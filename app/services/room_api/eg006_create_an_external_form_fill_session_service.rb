# frozen_string_literal: true

class RoomApi::Eg006CreateAnExternalFormFillSessionService
  attr_reader :args

  def initialize(args)
    @args = args
  end

  def worker
    #ds-snippet-start:Rooms6Step2
    configuration = DocuSign_Rooms::Configuration.new
    configuration.host = Rails.configuration.rooms_host
    api_client = DocuSign_Rooms::ApiClient.new(configuration)
    api_client.set_default_header('Authorization', "Bearer #{args[:access_token]}")
    #ds-snippet-end:Rooms6Step2

    #ds-snippet-start:Rooms6Step4
    rooms_api = DocuSign_Rooms::ExternalFormFillSessionsApi.new(api_client)
    rooms_api.create_external_form_fill_session(args[:account_id], body(args))
    #ds-snippet-end:Rooms6Step4
  end

  private

  #ds-snippet-start:Rooms6Step3
  def body(args)
    DocuSign_Rooms::ExternalFormFillSessionForCreate.new({
                                                           formId: args[:form_id],
                                                           roomId: args[:room_id],
                                                           xFrameAllowedUrl: "http://#{args[:allowed_host]}"
                                                         })
  end
  #ds-snippet-end:Rooms6Step3
end
