# frozen_string_literal: true

class RoomApi::Eg009AssignFormToFormGroupService
  attr_reader :args

  def initialize(session, request)
    @args = {
      form_id: request.params[:form_id],
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

    # Step 6 start
    form_groups_api = DocuSign_Rooms::FormGroupsApi.new(api_client)
    begin
      response = form_groups_api.assign_form_group_form(args[:form_group_id], args[:account_id], body)
    rescue Exception => e
      return { exception: 'Failed to assign a form to a form group' }
    end
    # Step 6 end
    response
  end

  def body
    # Step 5 start
    DocuSign_Rooms::FormGroupFormToAssign.new(
      {
        formId: args[:form_id]
      }
    )
    # Step 5 end
  end
end
