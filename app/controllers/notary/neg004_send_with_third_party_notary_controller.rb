# frozen_string_literal: true

require_relative '../../services/utils'

class Notary::Neg004SendWithThirdPartyNotaryController < EgController
  before_action -> { check_auth('Notary') }
  before_action -> { @example = Utils::ManifestUtils.new.get_example(@manifest, 4, 'Notary') }

  def create
    envelope_args = {
      signer_email: param_gsub(params['signerEmail']),
      signer_name: param_gsub(params['signerName']),
      doc_pdf: File.join('data', Rails.application.config.doc_pdf)
    }
    args = {
      account_id: session['ds_account_id'],
      base_path: session['ds_base_path'],
      access_token: session['ds_access_token'],
      envelope_args: envelope_args
    }
    results = Notary::Eg004SendWithThirdPartyNotaryService.new(args).worker
    @title = @example['ExampleName']
    @message = format_string(@example['ResultsPageText'], results['envelope_id'])
    render 'ds_common/example_done'
  rescue DocuSign_eSign::ApiError => e
    handle_error(e)
  end
end
