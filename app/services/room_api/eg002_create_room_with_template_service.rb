# frozen_string_literal: true

class RoomApi::Eg002CreateRoomWithTemplateService
  attr_reader :args

  def initialize(args)
    @args = args
  end

  def worker
    #ds-snippet-start:Rooms2Step2
    configuration = DocuSign_Rooms::Configuration.new
    configuration.host = Rails.configuration.rooms_host

    api_client = DocuSign_Rooms::ApiClient.new(configuration)
    api_client.set_default_header('Authorization', "Bearer #{args[:access_token]}")
    #ds-snippet-end:Rooms2Step2

    #ds-snippet-start:Rooms2Step5
    rooms_api = DocuSign_Rooms::RoomsApi.new(api_client)
    rooms_api.create_room(args[:account_id], body(args))
    #ds-snippet-end:Rooms2Step5
  end

  private

  def body(args)
    #ds-snippet-start:Rooms2Step4
    DocuSign_Rooms::RoomForCreate.new(
      {
        name: args[:room_name],
        roleId: args[:role_id],
        transactionSideId: 'listbuy',
        roomTemplateId: args[:template_id],
        officeId: args[:office_id],
        fieldData: DocuSign_Rooms::FieldDataForCreate.new(
          data: {
            address1: '123 EZ Street',
            address2: 'unit 10',
            city: 'Galaxian',
            state: 'US-HI',
            postalCode: '88888',
            companyRoomStatus: '5',
            comments: 'Lorem ipsum dolor sit amet, consectetur adipiscin'
          }
        )
      }
    )
    #ds-snippet-end:Rooms2Step4
  end
end
