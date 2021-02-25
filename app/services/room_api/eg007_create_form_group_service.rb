# frozen_string_literal: true

class RoomApi::Eg007CreateFormGroupService
  attr_reader :args

  def initialize(session, request)
    @args = {
        group_name: request.params[:group_name],
        account_id: session[:ds_account_id],
        access_token: session[:ds_access_token]
    }
  end

  def call
    worker
  end

  private

  def worker
    # Step 2 start
    configuration = DocuSign_Rooms::Configuration.new
    configuration.host = Rails.configuration.rooms_host

    api_client = DocuSign_Rooms::ApiClient.new(configuration)
    api_client.set_default_header("Authorization", "Bearer #{args[:access_token]}")
    # Step 2 end

    # Step 4 start
    rooms_api = DocuSign_Rooms::FormGroupsApi.new(api_client)
    rooms_api.create_form_group(args[:account_id], body)
    # Step 4 end
  end

  def body
    # Step 3 start
    DocuSign_Rooms::RoomForCreate.new(
        {
            name: args[:group_name]
        }
    )
    # Step 3 end
  end
end
