# frozen_string_literal: true

class ESign::Eg027Service
  include ApiCreator
  attr_reader :args, :request, :permission_profile_id

  def initialize(session, request)
    @args = {
      account_id: session[:ds_account_id],
      base_path: session[:ds_base_path],
      access_token: session[:ds_access_token]
    }
    @request = request
    @permission_profile_id = request.params[:lists]
  end

  def call
    # Step 3: Call the eSignature REST API
    accounts_api = create_account_api(args)
    delete_permission_profile  = accounts_api.delete_permission_profile(args[:account_id], permission_profile_id)
  end
end