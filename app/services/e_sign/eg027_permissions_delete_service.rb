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
    accounts_api.delete_permission_profile(args[:account_id], args[:permission_profile_id])
    #ds-snippet-end:eSign27Step3
  end
end
