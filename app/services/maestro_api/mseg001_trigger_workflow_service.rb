# frozen_string_literal: true

class MaestroApi::Mseg001TriggerWorkflowService
  include Utils
  attr_reader :args

  def initialize(args)
    @args = args
  end

  def get_workflow_definitions
    #ds-snippet-start:Maestro1Step2
    configuration = DocuSign_Maestro::Configuration.new
    configuration.host = args[:base_path]

    api_client = DocuSign_Maestro::ApiClient.new(configuration)
    api_client.set_default_header('Authorization', "Bearer #{args[:access_token]}")
    #ds-snippet-end:Maestro1Step2

    workflow_management_api = DocuSign_Maestro::WorkflowManagementApi.new(api_client)

    options = DocuSign_Maestro::GetWorkflowDefinitionsOptions.new
    options.status = 'active'
    workflow_management_api.get_workflow_definitions(args[:account_id], options)
  end

  def get_workflow_definition
    configuration = DocuSign_Maestro::Configuration.new
    configuration.host = args[:base_path]

    api_client = DocuSign_Maestro::ApiClient.new(configuration)
    api_client.set_default_header('Authorization', "Bearer #{args[:access_token]}")

    #ds-snippet-start:Maestro1Step3
    workflow_management_api = DocuSign_Maestro::WorkflowManagementApi.new(api_client)
    workflow_management_api.get_workflow_definition(args[:account_id], args[:workflow_id])
    #ds-snippet-end:Maestro1Step3
  end

  def trigger_workflow(workflow)
    configuration = DocuSign_Maestro::Configuration.new
    configuration.host = args[:base_path]

    api_client = DocuSign_Maestro::ApiClient.new(configuration)
    api_client.set_default_header('Authorization', "Bearer #{args[:access_token]}")

    #ds-snippet-start:Maestro1Step4
    trigger_payload = DocuSign_Maestro::TriggerPayload.new
    trigger_payload.instance_name = args[:instance_name]
    trigger_payload.participants = {}
    trigger_payload.payload = {
      signerEmail: args[:signer_email],
      signerName: args[:signer_name],
      ccEmail: args[:cc_email],
      ccName: args[:cc_name]
    }
    trigger_payload.metadata = {}

    mtid = URLUtils.new.get_parameter_value_from_url(workflow.trigger_url, 'mtid')
    mtsec = URLUtils.new.get_parameter_value_from_url(workflow.trigger_url, 'mtsec')
    trigger_options = DocuSign_Maestro::TriggerWorkflowOptions.new
    trigger_options.mtid = mtid
    trigger_options.mtsec = mtsec
    #ds-snippet-end:Maestro1Step4

    #ds-snippet-start:Maestro1Step5
    workflow_trigger_api = DocuSign_Maestro::WorkflowTriggerApi.new(api_client)
    workflow_trigger_api.trigger_workflow(args[:account_id], trigger_payload, trigger_options)
    #ds-snippet-end:Maestro1Step5
  end
end
