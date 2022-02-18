# frozen_string_literal: true

class ESign::Eg023IdvAuthenticationController < EgController
  before_action :check_auth

  def create
    begin
      envelope_args = {
        signer_email: param_gsub(params['signerEmail']),
        signer_name: param_gsub(params['signerName']),
        status: 'sent'
      }
      args = {
        account_id: session['ds_account_id'],
        base_path: session['ds_base_path'],
        access_token: session['ds_access_token'],
        envelope_args: envelope_args
      }

      results = ESign::Eg023IdvAuthenticationService.new(args).worker

      if results.to_s == "idv_not_enabled"
        @error_code = "IDENTITY_WORKFLOW_INVALID_ID"
        @error_message = "The identity workflow ID specified is not valid."
        @error_information = "Please contact <a target='_blank' rel='noopener noreferrer' href='https://support.docusign.com/'>Support</a> to enable ID verification in your account."
        render 'ds_common/error'
      else
        session[:envelope_id] = results.envelope_id
        @title = 'Envelope sent'
        @h1 = 'Envelope sent'
        @message = "The envelope has been created and sent!<br/>Envelope ID #{results.envelope_id}."
        render 'ds_common/example_done'
      end
    rescue DocuSign_eSign::ApiError => e
      error = JSON.parse e.response_body
      @error_code = error['errorCode']
      @error_message = error['message']
      render 'ds_common/error'
    end
  end

  # ***DS.snippet.0.end
end
