class AdminApi::Eg001CreateUserController < EgController
  include ApiCreator
  before_action :check_auth
  before_action -> { @example = Utils::ManifestUtils.new.get_example(@manifest, 1) }

  def create
    args = {
      account_id: session['ds_account_id'],
      base_path: session['ds_base_path'],
      access_token: session['ds_access_token'],
      organization_id: session['organization_id']
    }
    user_data = {
      user_name: param_gsub(params['user_name']),
      first_name: param_gsub(params['first_name']),
      last_name: param_gsub(params['last_name']),
      email: param_gsub(params['email']),
      auto_activate_memberships: true,
      accounts: [
        {
          id: args[:account_id],
          permission_profile: {
            id: request['permission_profile_id']
          },
          groups: [
            {
              id: request['group_id']
            }
          ]
        }
      ]
    }

    results = AdminApi::Eg001CreateUserService.new(args, user_data).worker

    @title = @example['ExampleName']
    @message = @example['ResultsPageText']
    @json = results.to_json.to_json
    render 'ds_common/example_done'
  rescue DocuSign_Admin::ApiError => e
    handle_error(e)
  end

  def get
    super
    session[:organization_id] = AdminApi::GetDataService.new(session).get_organization_id if session[:organization_id].nil?
    args = {
      account_id: session['ds_account_id'],
      base_path: session['ds_base_path'],
      access_token: session['ds_access_token']
    }

    accounts_api = create_account_api(args)
    @permission_profiles = accounts_api.list_permissions(args[:account_id]).permission_profiles

    groups_api = create_group_api(args)
    @groups = groups_api.list_groups(args[:account_id]).groups
  end
end
