# frozen_string_literal: true

class MaestroApi::Mseg002CancelWorkflowService
  attr_reader :args

  def initialize(args)
    @args = args
  end

  def get_instance_state
    configuration = DocuSign_Maestro::Configuration.new
    configuration.host = args[:base_path]

    api_client = DocuSign_Maestro::ApiClient.new(configuration)
    api_client.set_default_header('Authorization', "Bearer #{args[:access_token]}")

    workflow_instance_management_api = DocuSign_Maestro::WorkflowInstanceManagementApi.new(api_client)

    workflow_instance_management_api.get_workflow_instance(
      args[:account_id],
      args[:workflow_id],
      args[:instance_id]
    ).instance_state
  end

  def cancel_workflow_instance
    #ds-snippet-start:Maestro2Step2
    configuration = DocuSign_Maestro::Configuration.new
    configuration.host = args[:base_path]

    api_client = DocuSign_Maestro::ApiClient.new(configuration)
    api_client.set_default_header('Authorization', "Bearer #{args[:access_token]}")
    #ds-snippet-end:Maestro2Step2

    #ds-snippet-start:Maestro2Step3
    workflow_instance_management_api = DocuSign_Maestro::WorkflowInstanceManagementApi.new(api_client)

    workflow_instance_management_api.cancel_workflow_instance(args[:account_id], args[:instance_id])
    #ds-snippet-end:Maestro2Step3
  end
end
