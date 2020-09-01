# frozen_string_literal: true

class ESign::Eg029BrandsApplyToEnvelopeController < EgController
  include ApiCreator
  
  def get
    args = {
      account_id: session['ds_account_id'],
      base_path: session['ds_base_path'],
      access_token: session['ds_access_token']
    }
    accounts_api = create_account_api(args)
    brand_lists = accounts_api.list_brands(args[:account_id], options = DocuSign_eSign::ListBrandsOptions.default)
    @brand_names = brand_lists.brands
    super
  end

  def create
    minimum_buffer_min = 3
    if check_token(minimum_buffer_min)
    begin  
        results  = ESign::Eg029Service.new(session, request).call
        # Step 4. a) Call the eSignature API
        #         b) Display the JSON response  
        @title = 'Applying a Brand to an envelope'
        @h1 = 'Applying a Brand to an envelope'
        @message = "The envelope has been created and sent!<br/>Envelope ID #{results.envelope_id}."
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
