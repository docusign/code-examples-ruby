# frozen_string_literal: true

class ESign::Eg013AddDocToTemplateController < EgController
  before_action :check_auth

  def create
    template_id = session[:template_id]

    if template_id
      # 2. Call the worker method
      # More data validation would be a good idea here
      # Strip anything other than characters listed
      begin
        envelope_args = {
          signer_email: param_gsub(params['signerEmail']),
          signer_name: param_gsub(params['signerName']),
          cc_email: param_gsub(params['ccEmail']),
          cc_name: param_gsub(params['ccName']),
          item: param_gsub(params['item']),
          quantity: param_gsub(params['quantity']).to_i,
          signer_client_id: 1000,
          template_id: template_id,
          ds_return_url: "#{Rails.application.config.app_url}/ds_common-return"
        }
        args = {
          account_id: session['ds_account_id'],
          base_path: session['ds_base_path'],
          access_token: session['ds_access_token'],
          envelope_args: envelope_args
        }
        results = ESign::Eg013AddDocToTemplateService.new(args).worker
        # Save for use by other examples
        # which need an envelopeId
        session[:envelope_id] = results[:envelope_id] 
        # Redirect the user to the embedded signing
        # Don't use an iFrame!
        # State can be stored/recovered using the framework's session or a
        # query parameter on the returnUrl
        redirect_to results[:redirect_url]
      rescue DocuSign_eSign::ApiError => e
        error = JSON.parse e.response_body
        @error_code = error['errorCode']
        @error_message = error['message']
        render 'ds_common/error'
      end
    elsif !template_id
      @title = 'Use embedded signing from template and extra doc'
      @template_ok = false
    end
  end
end
