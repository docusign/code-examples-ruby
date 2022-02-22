# frozen_string_literal: true

class ESign::Eg033UnpausesSignatureWorkflowService
  attr_reader :args
  include ApiCreator

  def initialize(args)
    @args = args
  end

  def worker
    # Step 2. Construct your API headers
    configuration = DocuSign_eSign::Configuration.new
    configuration.host = args[:basePath]

    api_client = DocuSign_eSign::ApiClient.new configuration
    api_client.set_default_header('Authorization', "Bearer #{args[:accessToken]}")

    # Step 3. Construct the JSON body for your envelope
    workflow = DocuSign_eSign::Workflow.new(status: args[:status])

    envelope_definition = DocuSign_eSign::EnvelopeDefinition.new(workflow: workflow)

    # Step 4. Call the eSignature API
    envelopes_api = DocuSign_eSign::EnvelopesApi.new(api_client)

    update_options = DocuSign_eSign::UpdateOptions.new
    update_options.resend_envelope = true

    result = envelopes_api.update(
      args[:accountId],
      args[:envelopeId],
      envelope_definition,
      update_options
    )
  end
end
