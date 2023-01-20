# frozen_string_literal: true

class ESign::Eeg040SetDocumentVisibilityController < EgController
  before_action -> { check_auth('eSignature') }
  before_action -> { @example = Utils::ManifestUtils.new.get_example(@manifest, 40, 'eSignature') }

  def create
    envelope_args = {
      signer1_email: param_gsub(params['signer1Email']),
      signer1_name: param_gsub(params['signer1Name']),
      signer2_email: param_gsub(params['signer2Email']),
      signer2_name: param_gsub(params['signer2Name']),
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
    results = ESign::Eg040SetDocumentVisibilityService.new(args).worker
    @title = @example['ExampleName']
    @message = format_string(@example['ResultsPageText'], results['envelope_id'])
    render 'ds_common/example_done'
  rescue DocuSign_eSign::ApiError => e
    error = JSON.parse e.response_body

    if error['errorCode'] == 'ACCOUNT_LACKS_PERMISSIONS'
      @error_information = @example['CustomErrorTexts'][0]['ErrorMessage']

      @error_code = error['errorCode']
      @error_message = error['error_description'] || error['message']

      return render 'ds_common/error'
    end

    handle_error(e)
  end

  def get
    enableCFR = ESign::GetDataService.new(session[:ds_access_token], session[:ds_base_path]).cfr?(session[:ds_account_id])
    if enableCFR == 'enabled'
      session[:status_cfr] = 'enabled'
      @title = 'Not CFR Part 11 compatible'
      @error_information = @manifest['SupportingTexts']['CFRError']
      render 'ds_common/error'
    end
    super
  end
end
