# frozen_string_literal: true

class ESign::Eg037SmsDeliveryController < EgController
  before_action :check_auth

  def create
    begin
      envelope_args = {
        signer_email: param_gsub(params['signer_email']),
        signer_name: param_gsub(params['signer_name']),
        cc_email: param_gsub(params['cc_email']),
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
      @title = 'Envelope sent'
      @h1 = 'Envelope sent'
      @message = "The envelope has been created and sent!<br/>Envelope ID #{results['envelope_id']}."
      render 'ds_common/example_done'
    rescue DocuSign_eSign::ApiError => e
      handle_error(e)
    end
  end
end
