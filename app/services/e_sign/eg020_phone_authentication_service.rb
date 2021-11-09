# frozen_string_literal: true

class ESign::Eg020PhoneAuthenticationService
  include ApiCreator
  attr_reader :args, :envelope_args, :request, :session

  def initialize(request, session)
    @request = request
    @session = session
    @args = {
      account_id: session['ds_account_id'],
      base_path: session['ds_base_path'],
      access_token: session['ds_access_token'],
      envelope_args: @envelope_args
    }
    @envelope_args = {
      signer_email: request.params['signer_email'].gsub(/([^\w \-\@\.\,])+/, ''),
      signer_name: request.params['signer_name'].gsub(/([^\w \-\@\.\,])+/, ''),
      country_code: request.params['country_code'].gsub(/([^\w \-\@\.\,])+/, ''),
      phone_number: request.params['phone_number'].gsub(/([^\w \-\@\.\,])+/, ''),
      workflow_id: get_workflow(@args),
      status: 'sent'
    }
  end

  def call
    if session[:workflow_id].blank?
      return "phone_auth_not_enabled"
    end

    # Construct your envelope JSON body
    # Step 4 start
    envelope_definition = DocuSign_eSign::EnvelopeDefinition.new
    envelope_definition.email_subject = 'Please sign this document set'

    # Add the documents and create the document models
    pdf_filename = 'World_Wide_Corp_lorem.pdf'
    document1 = DocuSign_eSign::Document.new(
      # Create the DocuSign Document object
      documentBase64: Base64.encode64(File.binread(File.join('data', pdf_filename))),
      name: 'Lorem', # Can be different from actual file name
      fileExtension: 'pdf', # Many different document types are accepted
      documentId: '1' # A label used to reference the doc
    )

    envelope_definition.documents = [document1]

    # Create the signer recipient model
    signer1 = DocuSign_eSign::Signer.new
    signer1.email = envelope_args[:signer_email]
    signer1.name = envelope_args[:signer_name]
    signer1.role_name = ''
    signer1.note = ''
    signer1.status = 'created'
    signer1.delivery_method = 'email'
    signer1.recipient_id = '1'
    signer1.routing_order = '1'

    phone_number = DocuSign_eSign::RecipientIdentityPhoneNumber.new
    phone_number.country_code = envelope_args[:country_code]
    phone_number.number = envelope_args[:phone_number]

    input_option = DocuSign_eSign::RecipientIdentityInputOption.new
    input_option.name = 'phone_number_list'
    input_option.value_type = 'PhoneNumberList'
    input_option.phone_number_list = [phone_number]

    identity_verification = DocuSign_eSign::RecipientIdentityVerification.new
    identity_verification.workflow_id = session[:workflow_id]

    identity_verification.input_options = [input_option]

    signer1.identity_verification = identity_verification

    sign_here1 = DocuSign_eSign::SignHere.new
    sign_here1.name = 'SignHereTab'
    sign_here1.anchor_string = '/sn1/'
    sign_here1.anchor_units = 'pixels'
    sign_here1.anchor_x_offset = '20'
    sign_here1.anchor_y_offset = '10'

    # Add the tabs model (including the sign_here tabs) to the signer
    # The Tabs object wants arrays of the different field/tab types
    signer1_tabs = DocuSign_eSign::Tabs.new ({
      signHereTabs: [sign_here1]
    })
    signer1.tabs = signer1_tabs

    # Add the recipients to the Envelope object
    recipients = DocuSign_eSign::Recipients.new(
      signers: [signer1]
    )
    # Request that the envelope be sent by setting |status| to "sent"
    # To request that the envelope be created as a draft, set to "created"
    envelope_definition.recipients = recipients
    envelope_definition.status = envelope_args[:status]
    # Step 4 end

    # Call the eSignature REST API
    # Step 5 start
    envelope_api = create_envelope_api(args)
    results = envelope_api.create_envelope args[:account_id], envelope_definition
    # Step 5 end
  end

  def get_workflow(args)
    #Retrieve the workflow id

    begin
      # Step 3 start
      workflow_details = create_account_api(args)
      workflow_response = workflow_details.get_account_identity_verification(args[:account_id])

      # Check that idv authentication is enabled
      if workflow_response.identity_verification
        phone_auth_workflow = workflow_response.identity_verification.find{ |item| item.default_name == "Phone Authentication" }
        if phone_auth_workflow
          session[:workflow_id] = phone_auth_workflow.workflow_id
          return session[:workflow_id]
        else
          return ""
        end
      else
          return ""
      end
      # Step 3 end

    rescue DocuSign_eSign::ApiError => e
      error = JSON.parse e.response_body
      @error_code = e.code
      @error_message = error['error_description']
      render 'ds_common/error'
    end
  end
end