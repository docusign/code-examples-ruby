# frozen_string_literal: true

class ESign::Eg025Service
  include ApiCreator
  attr_reader :args, :permission_profile_id, :group_id

  def initialize(session, request)
    @args = {
      account_id: session[:ds_account_id],
      base_path: session[:ds_base_path],
      access_token: session[:ds_access_token]
    }
    @request = request
    @permission_profile_id = request.params[:lists]
    @group_id = request.params[:group_lists]
  end

  def call
    group_api = create_group_api(args)

    # Step 3: Construct the request body
    params = {groups: [{permissionProfileId: permission_profile_id, groupId:  group_id}]}
    
    # Step 4: Call the eSignature REST API
    result = group_api.update_groups(args[:account_id], params)
  end
end