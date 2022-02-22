# frozen_string_literal: true

class ESign::Eg026PermissionsChangeSingleSettingController < EgController
  include ApiCreator
  before_action :check_auth

  def get
     args = {
      account_id: session['ds_account_id'],
      base_path: session['ds_base_path'],
      access_token: session['ds_access_token']
    }
    accounts_api = create_account_api(args)
    permissions = accounts_api.list_permissions(args[:account_id],  options = DocuSign_eSign::ListPermissionsOptions.default)
    @permissions_lists = permissions.permission_profiles
    super
  end

  def create
    begin
      args = {
        account_id: session[:ds_account_id],
        base_path: session[:ds_base_path],
        access_token: session[:ds_access_token],
        permission_profile_id: params[:lists]
      }

      results  = ESign::Eg026PermissionsChangeSingleSettingService.new(args).worker
      # Step 4. a) Call the eSignature API
      #         b) Display the JSON response
      @title = 'Updating individual permission settings'
      @h1 = 'Updating individual permission settings'
      @message = "Existing permission profile was changed"
      @json = results.to_json.to_json
      render 'ds_common/example_done'

    rescue DocuSign_eSign::ApiError => e
      handle_error(e)
    end
  end
end
