# frozen_string_literal: true

class ESign::Eeg036DelayedRoutingController < EgController
  before_action -> { check_auth('eSignature') }
  before_action -> { @example = Utils::ManifestUtils.new.get_example(@manifest, 36, 'eSignature') }

  def create
    begin
      envelope_args = {
        signer1_email: param_gsub(params['signer1Email']),
        signer1_name: param_gsub(params['signer1Name']),
        signer2_email: param_gsub(params['signer2Email']),
        signer2_name: param_gsub(params['signer2Name']),
        delay: param_gsub(params['delay']),
        status: 'sent'
      }
      args = {
        account_id: session['ds_account_id'],
        base_path: session['ds_base_path'],
        access_token: session['ds_access_token'],
        envelope_args: envelope_args
      }
      results = ESign::Eg036DelayedRoutingService.new(args).worker
      session[:envelope_id] = results['envelope_id']
      @title = @example['ExampleName']
      @message = format_string(@example['ResultsPageText'], results['envelope_id'])
      render 'ds_common/example_done'
    rescue DocuSign_eSign::ApiError => e
      handle_error(e)
    end
  end

  def get
    enableCFR = ESign::GetDataService.new(session[:ds_access_token], session[:ds_base_path]).is_cfr(session[:ds_account_id])
    if enableCFR == "enabled"
      session[:status_cfr] = "enabled"
      @title = "Not CFR Part 11 compatible"
      @error_information = @manifest['SupportingTexts']['CFRError']
      render 'ds_common/error'
    end
    super
  end
end
