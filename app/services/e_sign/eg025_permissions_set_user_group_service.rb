# frozen_string_literal: true

class ESign::Eg025PermissionsSetUserGroupService
  attr_reader :args

  include ApiCreator

  def initialize(args)
    @args = args
  end

  def worker
    group_api = create_group_api(args)

    # Step 3: Construct the request body
    params = { groups: [{ permissionProfileId: args[:permission_profile_id], groupId: args[:group_id] }] }

    # Step 4: Call the eSignature REST API
    group_api.update_groups(args[:account_id], params)
  end
end
