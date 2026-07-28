# frozen_string_literal: true

class RoomApi::Eg008GrantOfficeAccessToFormGroupService
  attr_reader :args

  def initialize(args)
    @args = args
  end

  def worker
    #ds-snippet-start:Rooms8Step2
    configuration = DocuSign_Rooms::Configuration.new
    configuration.host = Rails.configuration.rooms_host

    api_client = DocuSign_Rooms::ApiClient.new(configuration)
    api_client.set_default_header('Authorization', "Bearer #{args[:access_token]}")
    #ds-snippet-end:Rooms8Step2

    #ds-snippet-start:Rooms8Step5
    form_groups_api = DocuSign_Rooms::FormGroupsApi.new(api_client)
    begin
      response, _status, headers = form_groups_api.grant_office_access_to_form_group_with_http_info(args[:form_group_id], args[:office_id], args[:account_id])

      remaining = headers['X-RateLimit-Remaining']
      reset = headers['X-RateLimit-Reset']

      if remaining && reset
        reset_date = Time.at(reset.to_i).utc
        puts "API calls remaining: #{remaining}"
        puts "Next Reset: #{reset_date}"
      end
    rescue Exception
      return { exception: 'Failed to grant office access to a form group' }
    end
    #ds-snippet-end:Rooms8Step5
    response
  end
end
