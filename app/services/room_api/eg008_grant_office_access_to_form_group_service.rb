# frozen_string_literal: true

class RoomApi::Eg008GrantOfficeAccessToFormGroupService
  attr_reader :args

  def initialize(session, request)
    @args = {
        office_id: request.params[:office_id],
        form_group_id: request.params[:form_group_id],
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

    # Step 5 start
    form_groups_api = DocuSign_Rooms::FormGroupsApi.new(api_client)
    begin
      response = form_groups_api.grant_office_access_to_form_group(args[:form_group_id], args[:office_id], args[:account_id])
    rescue Exception => e
      return {exception: 'Failed to grant office access to a form group'}
    end
    # Step 5 end
    response
  end
end
