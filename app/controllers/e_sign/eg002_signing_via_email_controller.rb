# frozen_string_literal: true

class ESign::Eg002SigningViaEmailController < EgController
  before_action :check_auth

  def create
    begin
      envelope_args = {
        signer_email: param_gsub(params['signerEmail']),
        signer_name: param_gsub(params['signerName']),
        cc_email: param_gsub(params['ccEmail']),
        cc_name: param_gsub(params['ccName']),
        status: 'sent'
      }
      args = {
        account_id: session['ds_account_id'],
        base_path: session['ds_base_path'],
        access_token: session['ds_access_token'],
        envelope_args: envelope_args
      }
      results = ESign::Eg002SigningViaEmailService.new(args).worker
      session[:envelope_id] = results['envelope_id']
      @title = 'Envelope sent'
      @h1 = 'Envelope sent'
      @message = "The envelope has been created and sent!<br/>Envelope ID #{results['envelope_id']}."
      render 'ds_common/example_done'
    rescue DocuSign_eSign::ApiError => e
      handle_error(e)
    end
  end
end
