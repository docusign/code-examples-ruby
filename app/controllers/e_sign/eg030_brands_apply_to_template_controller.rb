# frozen_string_literal: truebrand_lists = accounts_api.list_brands(args[:account_id], options = DocuSign_eSign::ListBrandsOptions.default)

class ESign::Eg030BrandsApplyToTemplateController < EgController
  include ApiCreator
  before_action :check_auth

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
    begin
      envelope_args = {
        signer_email: param_gsub(params[:signerEmail]),
        signer_name: param_gsub(params[:signerName]),
        cc_email: param_gsub(params[:ccEmail]),
        cc_name: param_gsub(params[:ccName]),
        brand_id: params[:brands],
        template_id: params[:templates],
        status: 'sent'
    
      }
      args = {
        account_id: session['ds_account_id'],
        base_path: session['ds_base_path'],
        access_token: session['ds_access_token'],
        envelope_args: envelope_args
      }

      results  = ESign::Eg030BrandsApplyToTemplateService.new(args).worker
      session[:envelope_id] = results.envelope_id

      # Step 4. a) Call the eSignature API
      #         b) Display the JSON response
      # brand_id = results.brands[0].brand_id
      @title = 'Applying a brand to an envelope using a template'
      @h1 = 'Applying a brand to an envelope using a template'
      @message = "The envelope has been created and sent!<br/>Envelope ID #{results.envelope_id}."
      @json = results.to_json.to_json
      render 'ds_common/example_done'

    rescue DocuSign_eSign::ApiError => e
      handle_error(e)
    end
  end
end
