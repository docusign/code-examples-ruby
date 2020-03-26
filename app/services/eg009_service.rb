# frozen_string_literal: true

class Eg009Service
  include ApiCreator
  attr_reader :args, :envelope_args

  def initialize(request, session, template_id)
    envelope_args = {
      signer_email: request.params['signerEmail'],
      signer_name: request.params['signerName'],
      cc_email: request.params['ccEmail'],
      cc_name: request.params['ccName'],
      template_id: template_id
    }

    @args = {
      account_id: session['ds_account_id'],
      base_path: session['ds_base_path'],
      access_token: session['ds_access_token'],
      envelope_args: envelope_args
    }
  end

  def call
    results = worker
  end

  private

  # ***DS.snippet.0.start
  def worker
    envelope_args = args[:envelope_args]
    # 1. Create the envelope request object
    envelope_definition = make_envelope(envelope_args)
    # 2. Call Envelopes::create API method
    # Exceptions will be caught by the calling function
    envelope_api = create_envelope_api(args)
    results = envelope_api.create_envelope args[:account_id], envelope_definition
    envelope_id = results.envelope_id
    { envelope_id: envelope_id }
  end

  def make_envelope(args)
    # Create the envelope definition with the template_id
    envelope_definition = DocuSign_eSign::EnvelopeDefinition.new({
                                                                   status: 'sent',
                                                                   templateId: args[:template_id]
                                                                 })
    # Create the template role elements to connect the signer and
    # cc recipients to the template
    signer = DocuSign_eSign::TemplateRole.new({
                                                email: args[:signer_email],
                                                name: args[:signer_name],
                                                roleName: 'signer'
                                              })
    # Create a cc template role
    cc = DocuSign_eSign::TemplateRole.new({
                                            email: args[:cc_email],
                                            name: args[:cc_name],
                                            roleName: 'cc'
                                          })
    # Add the TemplateRole objects to the envelope object
    envelope_definition.template_roles = [signer, cc]
    envelope_definition
  end
  # ***DS.snippet.0.end
end