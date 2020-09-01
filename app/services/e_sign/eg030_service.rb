# frozen_string_literal: true

class ESign::Eg030Service
  include ApiCreator
  attr_reader :envelope_args, :args, :session, :request

  def initialize(session, request)
    @envelope_args = {
      signer_email: request.params[:signerEmail].gsub(/([^\w \-\@\.\,])+/, ''),
      signer_name: request.params[:signerName].gsub(/([^\w \-\@\.\,])+/, ''),
      cc_email: request.params['ccEmail'].gsub(/([^\w \-\@\.\,])+/, ''),
      cc_name: request.params['ccName'].gsub(/([^\w \-\@\.\,])+/, ''),
      status: 'sent'

    }
    @args = {
      account_id: session['ds_account_id'],
      base_path: session['ds_base_path'],
      access_token: session['ds_access_token']
    }
    @session = session
    @request = request
  end

  def call
    # ***DS.snippet.0.start
    # Step 1. Obtain your OAuth token
    # Step 2. Construct your API headers
    envelope_api = create_envelope_api(args)
    # Step 3. Construct your envelope JSON body
    envelope_definition = make_envelope
    # Step 4. Call the eSignature REST API
    results = envelope_api.create_envelope args[:account_id], envelope_definition
    session[:envelope_id] = results.envelope_id
    results
    # ***DS.snippet.0.end
  end

  private

  def make_envelope
    # Create the envelope definition with the template_id
    envelope_definition = DocuSign_eSign::EnvelopeDefinition.new
    # envelope_definition.envelope_id_stamping = true
    envelope_definition.template_id = request.params[:templates]
    envelope_definition.brand_id = request.params[:brands]
    envelope_definition.status = envelope_args[:status]
    # Create the template role elements to connect the signer and cc recipients
    # to the template
    signer = DocuSign_eSign::TemplateRole.new({
                                                email: envelope_args[:signer_email],
                                                name: envelope_args[:signer_name],
                                                roleName: 'signer'
                                              })
    # Create a cc template role
    cc = DocuSign_eSign::TemplateRole.new({
                                            email: envelope_args[:cc_email],
                                            name: envelope_args[:cc_name],
                                            roleName: 'cc'
                                          })

    envelope_definition.template_roles = [signer, cc]
    envelope_definition
  end
end