# frozen_string_literal: true

class ESign::Eg030BrandsApplyToTemplateService
  attr_reader :args

  include ApiCreator

  def initialize(args)
    @args = args
  end

  def worker
    # ***DS.snippet.0.start
    # Step 1. Obtain your OAuth token
    # Step 2. Construct your API headers
    envelope_api = create_envelope_api(args)
    # Step 3. Construct your envelope JSON body
    envelope_definition = make_envelope(args[:envelope_args])
    # Step 4. Call the eSignature REST API
    envelope_api.create_envelope args[:account_id], envelope_definition
    # ***DS.snippet.0.end
  end

  private

  def make_envelope(envelope_args)
    # Create the envelope definition with the template_id
    envelope_definition = DocuSign_eSign::EnvelopeDefinition.new
    # envelope_definition.envelope_id_stamping = true
    envelope_definition.template_id = envelope_args[:template_id]
    envelope_definition.brand_id = envelope_args[:brand_id]
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
