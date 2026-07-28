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
    results, _status, headers = rooms_api.create_form_group_with_http_info(args[:account_id], body(args))

    remaining = headers['X-RateLimit-Remaining']
    reset = headers['X-RateLimit-Reset']

    if remaining && reset
      reset_date = Time.at(reset.to_i).utc
      puts "API calls remaining: #{remaining}"
      puts "Next Reset: #{reset_date}"
    end
    #ds-snippet-end:Rooms7Step4

    results
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
