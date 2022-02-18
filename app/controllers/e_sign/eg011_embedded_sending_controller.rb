# frozen_string_literal: true

class ESign::Eg011EmbeddedSendingController < EgController
  before_action :check_auth

  def create
    begin
      envelope_args = {
        signer_email: param_gsub(params['signerEmail']),
        signer_name: param_gsub(params['signerName']),
        cc_email: param_gsub(params['ccEmail']),
        cc_name: param_gsub(params['ccName']),
        status: 'created'
      }
    
      args = {
        account_id: session['ds_account_id'],
        base_path: session['ds_base_path'],
        access_token: session['ds_access_token'],
        starting_view: param_gsub(params['starting_view']),
        envelope_args: envelope_args,
        ds_return_url: "#{Rails.application.config.app_url}/ds_common-return"
      }

      results = ESign::Eg011EmbeddedSendingService.new(args).worker
      redirect_to results['redirect_url']
    rescue  DocuSign_eSign::ApiError => e
      handle_error(e)
    end
  end
end
