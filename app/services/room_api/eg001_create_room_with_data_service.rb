# frozen_string_literal: true

class RoomApi::Eg001CreateRoomWithDataService
  attr_reader :args

  def initialize(session, request)
    @args = {
        room_name:  request.params[:roomName],
        office_id:  RoomApi::GetDataService.new(session).get_offices[0]['officeId'],
        role_id:  RoomApi::GetDataService.new(session).get_roles[2]['roleId'],
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

    rooms_api = DocuSign_Rooms::RoomsApi.new(api_client)

    response = rooms_api.create_room(args[:account_id], body)
  end

  def body
    DocuSign_Rooms::RoomForCreate.new(
        {
            name: args[:room_name],
            roleId: args[:role_id],
            transactionSideId: "buy",
            fieldData: DocuSign_Rooms::FieldDataForCreate.new(
                data:{
                    address1: '123 EZ Street',
                    address2: 'unit 10',
                    city: 'Galaxian',
                    state: 'US-HI',
                    postalCode: '88888',
                    companyRoomStatus: '5',
                    comments: 'Lorem ipsum dolor sit amet, consectetur adipiscin'
                })
        }
    )
  end
end