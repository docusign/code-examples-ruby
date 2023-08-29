# frozen_string_literal: true

class ESign::Eeg037SmsDeliveryController < EgController
  before_action -> { check_auth('eSignature') }
  before_action -> { @example = Utils::ManifestUtils.new.get_example(@manifest, 37, 'eSignature') }

  def create
    envelope_args = {
      delivery_method: param_gsub(params['delivery_method']),
      signer_name: param_gsub(params['signer_name']),
      cc_name: param_gsub(params['cc_name']),
      cc_phone_number: param_gsub(params['cc_phone_number']),
      cc_country_code: param_gsub(params['cc_country_code']),
      phone_number: param_gsub(params['phone_number']),
      country_code: param_gsub(params['country_code']),
      status: 'sent'
    }
    args = {
      account_id: session['ds_account_id'],
      base_path: session['ds_base_path'],
      access_token: session['ds_access_token'],
      envelope_args: envelope_args
    }

    results = ESign::Eg037SmsDeliveryService.new(args).worker
    session[:envelope_id] = results['envelope_id']
    @title = @example['ExampleName']
    @message = format_string(@example['ResultsPageText'], results['envelope_id'])
    render 'ds_common/example_done'
  rescue DocuSign_eSign::ApiError => e
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
