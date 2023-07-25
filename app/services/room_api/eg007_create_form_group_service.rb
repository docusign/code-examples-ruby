# frozen_string_literal: true

class RoomApi::Eg007CreateFormGroupService
  attr_reader :args

  def initialize(args)
    @args = args
  end

  def worker
    #ds-snippet-start:Rooms7Step2
    configuration = DocuSign_Rooms::Configuration.new
    configuration.host = Rails.configuration.rooms_host

    api_client = DocuSign_Rooms::ApiClient.new(configuration)
    api_client.set_default_header('Authorization', "Bearer #{args[:access_token]}")
    #ds-snippet-end:Rooms7Step2

    #ds-snippet-start:Rooms7Step4
    rooms_api = DocuSign_Rooms::FormGroupsApi.new(api_client)
    rooms_api.create_form_group(args[:account_id], body(args))
    #ds-snippet-end:Rooms7Step4
  end

  private

  def body(args)
    #ds-snippet-start:Rooms7Step3
    DocuSign_Rooms::RoomForCreate.new(
      {
        name: args[:group_name]
      }
    )
    #ds-snippet-end:Rooms7Step3
  end
end
