# frozen_string_literal: true

class Eg024PermissionCreateController < EgController
  def create
    minimum_buffer_min = 3
    if check_token(minimum_buffer_min)
    begin  
        results  = ::Eg024Service.new(session, request).call
        # Step 4. a) Call the eSignature API
        #         b) Display the JSON response  
        @title = 'Creating a permission profile'
        @h1 = 'Creating a permission profile'
        @message = "Permission profile was created"
        @json = results.to_json.to_json
        render 'ds_common/example_done'

      rescue DocuSign_eSign::ApiError => e
        error = JSON.parse e.response_body
        @error_code = error['errorCode']
        @error_message = error['message']
        render 'ds_common/error'
      end
    else
      flash[:messages] = 'Sorry, you need to re-authenticate.'
      # We could store the parameters of the requested operation so it could be restarted
      # automatically. But since it should be rare to have a token issue here,
      # we'll make the user re-enter the form data after authentication
      redirect_to '/'
    end
  end
end
