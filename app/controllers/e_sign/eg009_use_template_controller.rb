# frozen_string_literal: true

class ESign::Eg009UseTemplateController < EgController
  before_action :check_auth

  def create
    template_id = session[:template_id]

    if template_id
      begin
        envelope_args = {
          signer_email: params['signerEmail'],
          signer_name: params['signerName'],
          cc_email: params['ccEmail'],
          cc_name: params['ccName'],
          template_id: template_id
        }
    
        args = {
          account_id: session['ds_account_id'],
          base_path: session['ds_base_path'],
          access_token: session['ds_access_token'],
          envelope_args: envelope_args
        }

        results = ESign::Eg009UseTemplateService.new(args).worker
        # results is an object that implements ArrayAccess. Convert to a regular array:
        @title = 'Envelope sent'
        @h1 = 'Envelope sent'
        @message = "The envelope has been created and sent!<br/>Envelope ID #{results[:envelope_id]}."
        render 'ds_common/example_done'
      rescue  DocuSign_eSign::ApiError => e
        handle_error(e)
      end
    elsif !template_id
      @title = 'Use a template to send an envelope'
      @template_ok = false
    end
  end
end
