# frozen_string_literal: true

class ESign::Eg030BrandsApplyToTemplateService
  attr_reader :args

  include ApiCreator

  def initialize(args)
    @args = args
  end

  def worker
    # Obtain your OAuth token
    # Construct your API headers
    envelope_api = create_envelope_api(args)
    # Construct your envelope JSON body
    #ds-snippet-start:eSign30Step3
    envelope_definition = make_envelope(args[:envelope_args])
    #ds-snippet-end:eSign30Step3
    # Call the eSignature REST API
    #ds-snippet-start:eSign30Step4
    results, _status, headers = envelope_api.create_envelope_with_http_info args[:account_id], envelope_definition

    remaining = headers['X-RateLimit-Remaining']
    reset = headers['X-RateLimit-Reset']

    if remaining && reset
      reset_date = Time.at(reset.to_i).utc
      puts "API calls remaining: #{remaining}"
      puts "Next Reset: #{reset_date}"
    end
    #ds-snippet-end:eSign30Step4

    results
  end

  private

  #ds-snippet-start:eSign30Step3
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
  #ds-snippet-end:eSign30Step3
end
