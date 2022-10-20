# frozen_string_literal: true

class ESign::Eg025PermissionsSetUserGroupController < EgController
  include ApiCreator
  before_action :check_auth
  before_action -> { @example = Utils::ManifestUtils.new.get_example(@manifest, 25) }

  def get
    args = {
      account_id: session['ds_account_id'],
      base_path: session['ds_base_path'],
      access_token: session['ds_access_token']
    }
    accounts_api = create_account_api(args)
    permissions = accounts_api.list_permissions(args[:account_id], DocuSign_eSign::ListPermissionsOptions.default)
    @permissions_lists = permissions.permission_profiles
    # Get a user group
    group_api = create_group_api(args)
    @group_lists = group_api.list_groups(args[:account_id], DocuSign_eSign::ListGroupsOptions.default)
    super
  end

  def create
    args = {
      account_id: session[:ds_account_id],
      base_path: session[:ds_base_path],
      access_token: session[:ds_access_token],
      permission_profile_id: params[:lists],
      group_id: params[:group_lists]
    }

    results = ESign::Eg025PermissionsSetUserGroupService.new(args).worker
    # Step 4. a) Call the eSignature API
    #         b) Display the JSON response
    @title = @example['ExampleName']
    @json = results.to_json.to_json
    render 'ds_common/example_done'
  rescue DocuSign_eSign::ApiError => e
    handle_error(e)
  end
end
