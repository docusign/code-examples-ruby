# frozen_string_literal: true

class ESign::Eg033UnpausesSignatureWorkflowService
  attr_reader :args

  include ApiCreator

  def initialize(args)
    @args = args
  end

  def worker
    #ds-snippet-start:eSign33Step2
    configuration = DocuSign_eSign::Configuration.new
    configuration.host = args[:basePath]

    api_client = DocuSign_eSign::ApiClient.new configuration
    api_client.set_default_header('Authorization', "Bearer #{args[:accessToken]}")
    #ds-snippet-end:eSign33Step2

    #ds-snippet-start:eSign33Step3
    workflow = DocuSign_eSign::Workflow.new(status: args[:status])

    envelope_definition = DocuSign_eSign::EnvelopeDefinition.new(workflow: workflow)
    #ds-snippet-end:eSign33Step3

    #ds-snippet-start:eSign33Step4
    envelopes_api = DocuSign_eSign::EnvelopesApi.new(api_client)

    update_options = DocuSign_eSign::UpdateOptions.new
    update_options.resend_envelope = true

    envelopes_api.update(
      args[:accountId],
      args[:envelopeId],
      envelope_definition,
      update_options
    )
  end
  #ds-snippet-end:eSign33Step4
end
