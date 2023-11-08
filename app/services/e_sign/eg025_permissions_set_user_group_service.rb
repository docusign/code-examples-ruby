# frozen_string_literal: true

class ESign::Eg025PermissionsSetUserGroupService
  attr_reader :args

  include ApiCreator

  def initialize(args)
    @args = args
  end

  def worker
    group_api = create_group_api(args)

    # Construct the request body
    #ds-snippet-start:eSign25Step3
    params = { groups: [{ permissionProfileId: args[:permission_profile_id], groupId: args[:group_id] }] }
    #ds-snippet-end:eSign25Step3

    # Call the eSignature REST API
    #ds-snippet-start:eSign25Step4
    group_api.update_groups(args[:account_id], params)
    #ds-snippet-end:eSign25Step4
  end
end
