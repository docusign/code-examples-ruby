# frozen_string_literal: true

require_relative '../../services/utils'

class ConnectedFields::Feg001SetConnectedFieldsController < EgController
  before_action -> { check_auth('ConnectedFields') }
  before_action -> { @example = Utils::ManifestUtils.new.get_example(@manifest, 1, 'ConnectedFields') }

  def get
    super
    args = {
      account_id: session['ds_account_id'],
      access_token: session['ds_access_token'],
      extensions_base_path: 'https://api-d.docusign.com'
    }

    example_service = ConnectedFields::Eg001SetConnectedFieldsService.new(args)
    @apps = example_service.get_tab_groups

    return unless @apps.nil? || @apps.empty?

    additional_page_data = example['AdditionalPage'].find { |p| p['Name'] == 'no_verification_app' }

    @title = @example['ExampleName']
    @message = additional_page_data['ResultsPageText']
    render 'ds_common/example_done'
  end

  def create
    envelope_args = {
      signer_email: param_gsub(params['signerEmail']),
      signer_name: param_gsub(params['signerName']),
      doc_pdf: File.join('data', Rails.application.config.doc_pdf)
    }
    args = {
      account_id: session['ds_account_id'],
      base_path: session['ds_base_path'],
      extensions_base_path: 'https://api-d.docusign.com',
      access_token: session['ds_access_token'],
      selected_app_id: param_gsub(params['appId']),
      envelope_args: envelope_args
    }

    example_service = ConnectedFields::Eg001SetConnectedFieldsService.new(args)
    apps = example_service.get_tab_groups
    selected_app = apps.find { |app| app['appId'] == args[:selected_app_id] }

    results = example_service.send_envelope selected_app
    session[:envelope_id] = results['envelope_id']
    @title = @example['ExampleName']
    @message = format_string(@example['ResultsPageText'], results['envelope_id'])
    render 'ds_common/example_done'
  rescue DocuSign_eSign::ApiError => e
    handle_error(e)
  end
end
