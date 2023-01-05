# frozen_string_literal: true

class ESign::Eeg029BrandsApplyToEnvelopeController < EgController
  include ApiCreator
  before_action -> { check_auth('eSignature') }
  before_action -> { @example = Utils::ManifestUtils.new.get_example(@manifest, 29, 'eSignature') }

  def get
    args = {
      account_id: session['ds_account_id'],
      base_path: session['ds_base_path'],
      access_token: session['ds_access_token']
    }
    accounts_api = create_account_api(args)
    brand_lists = accounts_api.list_brands(args[:account_id], DocuSign_eSign::ListBrandsOptions.default)
    @brand_names = brand_lists.brands
    super
  end

  def create
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

    results = ESign::Eg029BrandsApplyToEnvelopeService.new(args).worker
    session[:envelope_id] = results.envelope_id

    # Step 4. a) Call the eSignature API
    #         b) Display the JSON response
    @title = @example['ExampleName']
    @message = format_string(@example['ResultsPageText'], results.envelope_id)
    @json = results.to_json.to_json
    render 'ds_common/example_done'
  rescue DocuSign_eSign::ApiError => e
    handle_error(e)
  end
end
