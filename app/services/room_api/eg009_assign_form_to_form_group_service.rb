# frozen_string_literal: true

class RoomApi::Eg009AssignFormToFormGroupService
  attr_reader :args

  def initialize(args)
    @args = args
  end

  def worker
    #ds-snippet-start:Rooms9Step2
    configuration = DocuSign_Rooms::Configuration.new
    configuration.host = Rails.configuration.rooms_host

    api_client = DocuSign_Rooms::ApiClient.new(configuration)
    api_client.set_default_header('Authorization', "Bearer #{args[:access_token]}")
    #ds-snippet-end:Rooms9Step2

    #ds-snippet-start:Rooms9Step6
    form_groups_api = DocuSign_Rooms::FormGroupsApi.new(api_client)
    begin
      response = form_groups_api.assign_form_group_form(args[:form_group_id], args[:account_id], body(args))
    rescue Exception
      return { exception: 'Failed to assign a form to a form group' }
    end
    #ds-snippet-end:Rooms9Step6
    response
  end

  private

  def body(args)
    #ds-snippet-start:Rooms9Step5
    DocuSign_Rooms::FormGroupFormToAssign.new(
      {
        formId: args[:form_id]
      }
    )
    #ds-snippet-end:Rooms9Step5
  end
end
