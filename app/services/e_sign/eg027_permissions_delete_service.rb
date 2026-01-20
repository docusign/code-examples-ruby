# frozen_string_literal: true

class ESign::Eg027PermissionsDeleteService
  attr_reader :args

  include ApiCreator

  def initialize(args)
    @args = args
  end

  def worker
    # Call the eSignature REST API
    #ds-snippet-start:eSign27Step3
    accounts_api = create_account_api(args)
    results, _status, headers = accounts_api.delete_permission_profile_with_http_info(args[:account_id], args[:permission_profile_id])

    remaining = headers['X-RateLimit-Remaining']
    reset = headers['X-RateLimit-Reset']

    if remaining && reset
      reset_date = Time.at(reset.to_i).utc
      puts "API calls remaining: #{remaining}"
      puts "Next Reset: #{reset_date}"
    end
    #ds-snippet-end:eSign27Step3

    results
  end
end
