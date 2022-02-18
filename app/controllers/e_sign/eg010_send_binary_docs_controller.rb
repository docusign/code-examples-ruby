class ESign::Eg010SendBinaryDocsController < EgController
  before_action :check_auth

  def create
    begin
      envelope_args = {
        # Validation: Delete any non-usual characters
        signer_email: param_gsub(params['signerEmail']),
        signer_name: param_gsub(params['signerName']),
        cc_email: param_gsub(params['ccEmail']),
        cc_name: param_gsub(params['ccName'])
      }
    
      args = {
        account_id: session['ds_account_id'],
        base_path: session['ds_base_path'],
        access_token: session['ds_access_token'],
        envelope_args: envelope_args
      }

      results = ESign::Eg010SendBinaryDocsService.new(args).worker
      session[:envelope_id] = results['envelope_id']
      @title = 'Envelope sent'
      @h1 = 'Envelope sent'
      @message = "The envelope has been created and sent!<br/>Envelope ID #{results['envelope_id']}."
      render 'ds_common/example_done'
    rescue Net::HTTPError => e
      if !e.response.nil?
        json_response = JSON.parse e.response
        @error_code = json_response['errorCode']
        @error_message = json_response['message']
      else
        @error_code = 'API request problem'
        @error_message = e.to_s
      end
    end
  end
end
