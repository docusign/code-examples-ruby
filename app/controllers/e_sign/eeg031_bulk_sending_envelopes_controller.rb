# frozen_string_literal: true

class ESign::Eeg031BulkSendingEnvelopesController < EgController
  before_action -> { check_auth('eSignature') }
  before_action -> { @example = Utils::ManifestUtils.new.get_example(@manifest, 31, 'eSignature') }

  def create
    signers = {
      signer_email: param_gsub(params['signerEmail1']),
      signer_name: param_gsub(params['signerName1']),
      cc_email: param_gsub(params['ccEmail1']),
      cc_name: param_gsub(params['ccName1']),
      status: 'created',

      signer_email1: param_gsub(params['signerEmail2']),
      signer_name1: param_gsub(params['signerName2']),
      cc_email1: param_gsub(params['ccEmail2']),
      cc_name1: param_gsub(params['ccName2'])
    }
    args = {
      account_id: session['ds_account_id'],
      base_path: session['ds_base_path'],
      access_token: session['ds_access_token']
    }

    results = ESign::Eg031BulkSendingEnvelopesService.new(args, signers).worker
    # Step 4. a) Call the eSignature API
    #         b) Display the JSON response
    @title = @example['ExampleName']
    @message = @example['ResultsPageText']
    @json =  results.to_json.to_json

    render 'ds_common/example_done'
  rescue DocuSign_eSign::ApiError => e
    handle_error(e)
  end
end
