# frozen_string_literal: true

class ESign::Eg027PermissionsDeleteController < EgController
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

      results  = ESign::Eg027PermissionsDeleteService.new(args).worker
      # Step 4. a) Call the eSignature API
      #         b) Display the JSON response
      @title = 'Permission profile from an account was deleted'
      @h1 = 'Permission profile from an account was deleted'
      @message = "Permission profile #{params[:lists]}  was deleted"
      render 'ds_common/example_done'

    rescue DocuSign_eSign::ApiError => e
      handle_error(e)
    end
  end
end
