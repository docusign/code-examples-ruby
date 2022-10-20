# frozen_string_literal: true

class RoomApi::Eg007CreateFormGroupService
  attr_reader :args

  def initialize(args)
    @args = args
  end

  def worker
    # Step 2 start
    configuration = DocuSign_Rooms::Configuration.new
    configuration.host = Rails.configuration.rooms_host

    api_client = DocuSign_Rooms::ApiClient.new(configuration)
    api_client.set_default_header('Authorization', "Bearer #{args[:access_token]}")
    # Step 2 end

    # Step 4 start
    rooms_api = DocuSign_Rooms::FormGroupsApi.new(api_client)
    rooms_api.create_form_group(args[:account_id], body(args))
    # Step 4 end
  end

  private

  def body(args)
    # Step 3 start
    DocuSign_Rooms::RoomForCreate.new(
      {
        name: args[:group_name]
      }
    )
    # Step 3 end
  end
end
