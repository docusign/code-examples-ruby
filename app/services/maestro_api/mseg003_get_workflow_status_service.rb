# frozen_string_literal: true

class MaestroApi::Mseg003GetWorkflowStatusService
  attr_reader :args

  def initialize(args)
    @args = args
  end

  def get_instance_state
    #ds-snippet-start:Maestro3Step2
    configuration = DocuSign_Maestro::Configuration.new
    configuration.host = args[:base_path]

    api_client = DocuSign_Maestro::ApiClient.new(configuration)
    api_client.set_default_header('Authorization', "Bearer #{args[:access_token]}")
    #ds-snippet-end:Maestro3Step2

    #ds-snippet-start:Maestro3Step3
    workflow_instance_management_api = DocuSign_Maestro::WorkflowInstanceManagementApi.new(api_client)

    workflow_instance_management_api.get_workflow_instance(
      args[:account_id],
      args[:workflow_id],
      args[:instance_id]
    )
    #ds-snippet-end:Maestro3Step3
  end
end
