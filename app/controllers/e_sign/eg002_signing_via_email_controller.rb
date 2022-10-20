# frozen_string_literal: true

require_relative '../../services/utils'

class ESign::Eg002SigningViaEmailController < EgController
  before_action :check_auth
  before_action -> { @example = Utils::ManifestUtils.new.get_example(@manifest, 2) }

  def create
    envelope_args = {
      signer_email: param_gsub(params['signerEmail']),
      signer_name: param_gsub(params['signerName']),
      cc_email: param_gsub(params['ccEmail']),
      cc_name: param_gsub(params['ccName']),
      status: 'sent',
      doc_docx: File.join('data', Rails.application.config.doc_docx),
      doc_pdf: File.join('data', Rails.application.config.doc_pdf)
    }
    args = {
      account_id: session['ds_account_id'],
      base_path: session['ds_base_path'],
      access_token: session['ds_access_token'],
      envelope_args: envelope_args
    }
    results = ESign::Eg002SigningViaEmailService.new(args).worker
    session[:envelope_id] = results['envelope_id']
    @title = @example['ExampleName']
    @message = format_string(@example['ResultsPageText'], results['envelope_id'])
    render 'ds_common/example_done'
  rescue DocuSign_eSign::ApiError => e
    handle_error(e)
  end
end
