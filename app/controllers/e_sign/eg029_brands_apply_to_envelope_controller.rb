# frozen_string_literal: true

class ESign::Eg029BrandsApplyToEnvelopeController < EgController
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
    super
  end

  def create
    begin
      envelope_args = {
        signer_email: param_gsub(params[:signerEmail]),
        signer_name: param_gsub(params[:signerName]),
        brand_id: params[:brands],
        status: 'sent'
    
      }
      args = {
        account_id: session['ds_account_id'],
        base_path: session['ds_base_path'],
        access_token: session['ds_access_token'],
        envelope_args: envelope_args
      }

      results  = ESign::Eg029BrandsApplyToEnvelopeService.new(args).worker
      session[:envelope_id] = results.envelope_id

      # Step 4. a) Call the eSignature API
      #         b) Display the JSON response
      @title = 'Applying a Brand to an envelope'
      @h1 = 'Applying a Brand to an envelope'
      @message = "The envelope has been created and sent!<br/>Envelope ID #{results.envelope_id}."
      @json = results.to_json.to_json
      render 'ds_common/example_done'

    rescue DocuSign_eSign::ApiError => e
      handle_error(e)
    end
  end
end
