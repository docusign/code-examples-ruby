# frozen_string_literal: true

class ESign::Eg034UseConditionalRecipientsController < EgController
  before_action :check_auth

  def create
    begin
      signers = {
        signerEmail1: request['signerEmail1'],
        signerName1: request['signerName1'],
  
        signerEmailNotChecked: request['signerEmailNotChecked'],
        signerNameNotChecked: request['signerNameNotChecked'],
  
        signerEmailChecked: request['signerEmailChecked'],
        signerNameChecked: request['signerNameChecked']
      }
  
      args = {
        accountId: session['ds_account_id'],
        basePath: session['ds_base_path'],
        accessToken: session['ds_access_token']
      }

      results = ESign::Eg034UseConditionalRecipientsService.new(args, signers).worker
      @envelop_id = results.to_hash[:envelopeId].to_s
      render 'e_sign/eg034_use_conditional_recipients/return'
    rescue DocuSign_eSign::ApiError => e
      error = JSON.parse e.response_body
      @error_code = error['errorCode']
      if error['errorCode']["WORKFLOW_UPDATE_RECIPIENTROUTING_NOT_ALLOWED"]
        @error_message = "Update to the workflow with recipient routing is not allowed for your account!"
        @error_information = "Please contact with our <a href='https://developers.docusign.com/support/' target='_blank'>support team</a> to resolve this issue."
      else 
        @error_message = error['message']
      end
      render 'ds_common/error'
    end
  end
end
