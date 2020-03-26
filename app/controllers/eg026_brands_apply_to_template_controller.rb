# frozen_string_literal: truebrand_lists = accounts_api.list_brands(args[:account_id], options = DocuSign_eSign::ListBrandsOptions.default)

class Eg026BrandsApplyToTemplateController < EgController
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
    # get the template lists 
    template_api = create_template_api(args)
    template_lists = template_api.list_templates(args[:account_id], options = DocuSign_eSign::ListTemplatesOptions.default)
    @templates = template_lists.envelope_templates
    super
  end

  def create
    minimum_buffer_min = 3
    if check_token(minimum_buffer_min)
    begin  
        results  = ::Eg026Service.new(session, request).call
        # Step 4. a) Call the eSignature API
        #         b) Display the JSON response  
        # brand_id = results.brands[0].brand_id
        @title = 'Applying a brand to a template'
        @h1 = 'Applying a brand to a template'
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
