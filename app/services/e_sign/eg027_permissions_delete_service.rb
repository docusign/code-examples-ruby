# frozen_string_literal: true

class ESign::Eg027PermissionsDeleteService
  attr_reader :args
  include ApiCreator

  def initialize(args)
    @args = args
  end

  def worker
    # Step 3: Call the eSignature REST API
    accounts_api = create_account_api(args)
    delete_permission_profile  = accounts_api.delete_permission_profile(args[:account_id], args[:permission_profile_id])
  end
end