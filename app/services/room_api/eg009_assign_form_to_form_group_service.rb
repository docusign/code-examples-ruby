# frozen_string_literal: true

class RoomApi::Eg009AssignFormToFormGroupService
  attr_reader :args

  def initialize(args)
    @args = args
  end

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
      response = form_groups_api.assign_form_group_form(args[:form_group_id], args[:account_id], body(args))
    rescue Exception => e
      return { exception: 'Failed to assign a form to a form group' }
    end
    # Step 6 end
    response
  end

  private

  def body(args)
    # Step 5 start
    DocuSign_Rooms::FormGroupFormToAssign.new(
      {
        formId: args[:form_id]
      }
    )
    # Step 5 end
  end
end
