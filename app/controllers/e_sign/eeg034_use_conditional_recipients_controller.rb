# frozen_string_literal: true

class ESign::Eeg034UseConditionalRecipientsController < EgController
  before_action -> { check_auth('eSignature') }
  before_action -> { @example = Utils::ManifestUtils.new.get_example(@manifest, 34, 'eSignature') }

  def create
    signers = {
      signerEmail1: request['signerEmail1'],
      signerName1: request['signerName1'],

      signerEmailNotChecked: request['signerEmailNotChecked'],
      signerNameNotChecked: request['signerNameNotChecked'],

      signerEmailChecked: request['signerEmailChecked'],
      signerNameChecked: request['signerNameChecked']
    }

    args = {
      accountId: session['ds_account_id'],
      basePath: session['ds_base_path'],
      accessToken: session['ds_access_token']
    }

    results = ESign::Eg034UseConditionalRecipientsService.new(args, signers).worker
    @envelop_id = results.to_hash[:envelopeId].to_s
    render 'e_sign/eeg034_use_conditional_recipients/return'
  rescue DocuSign_eSign::ApiError => e
    error = JSON.parse e.response_body
    @error_code = error['errorCode']
    if error['errorCode']['WORKFLOW_UPDATE_RECIPIENTROUTING_NOT_ALLOWED']
      @error_message = @example['CustomErrorTexts'][0]['ErrorMessage']
      @error_information = @example['CustomErrorTexts'][0]['ErrorMessage']
    else
      @error_message = error['message']
    end
    render 'ds_common/error'
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
