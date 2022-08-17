# frozen_string_literal: true

class ESign::Eg040SetDocumentVisibilityController < EgController
  before_action :check_auth

  def create
    begin
      envelope_args = {
        signer1_email: param_gsub(params['signer1Email']),
        signer1_name: param_gsub(params['signer1Name']),
        signer2_email: param_gsub(params['signer2Email']),
        signer2_name: param_gsub(params['signer2Name']),
        cc_email: param_gsub(params['ccEmail']),
        cc_name: param_gsub(params['ccName']),
        status: 'sent',
        doc_docx: File.join('data', Rails.application.config.doc_docx),
        doc_pdf: File.join('data', Rails.application.config.doc_pdf)
      }
      args = {
        account_id: session['ds_account_id'],
        base_path: session['ds_base_path'],
        access_token: session['ds_access_token'],
        envelope_args: envelope_args
      }
      results = ESign::Eg040SetDocumentVisibilityService.new(args).worker
      @title = 'Envelope sent'
      @h1 = 'Envelope sent'
      @message = "The envelope has been created and sent!<br/>Envelope ID #{results['envelope_id']}."
      render 'ds_common/example_done'
    rescue DocuSign_eSign::ApiError => e
      error = JSON.parse e.response_body

      if error['errorCode'] == "ACCOUNT_LACKS_PERMISSIONS"
        @error_information = '<p>See <a href="https://developers.docusign.com/docs/esign-rest-api/how-to/set-document-visibility/">How to set document visibility for envelope recipients</a> in
          the DocuSign Developer Center for instructions on how to
          enable document visibility in your developer account.</p>'

        @error_code = error['errorCode']
        @error_message = error['error_description'] || error['message']

        return render 'ds_common/error'
      end

      handle_error(e)
    end
  end
end
