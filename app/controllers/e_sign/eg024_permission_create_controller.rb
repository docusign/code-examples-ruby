# frozen_string_literal: true

class ESign::Eg024PermissionCreateController < EgController
  before_action :check_auth
  before_action -> { @example = Utils::ManifestUtils.new.get_example(@manifest, 24) }

  def create
    args = {
      account_id: session[:ds_account_id],
      base_path: session[:ds_base_path],
      access_token: session[:ds_access_token],
      permission_profile_name: params[:permission_profile_name]
    }

    results = ESign::Eg024PermissionCreateService.new(args).worker
    # Step 4. a) Call the eSignature API
    #         b) Display the JSON response
    @title = @example['ExampleName']
    @message = 'Permission profile was created'
    @json = results.to_json.to_json
    render 'ds_common/example_done'
  rescue DocuSign_eSign::ApiError => e
    handle_error(e)
  end
end
