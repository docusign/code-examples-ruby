# frozen_string_literal: true

class ESign::Eg014CollectPaymentController < EgController
  before_action :check_auth
  before_action -> { @example = Utils::ManifestUtils.new.get_example(@manifest, 14) }

  def create
    envelope_args = {
      signer_email: param_gsub(params['signerEmail']),
      signer_name: param_gsub(params['signerName']),
      cc_email: param_gsub(params['ccEmail']),
      cc_name: param_gsub(params['ccName']),
      gateway_account_id: Rails.application.config.gateway_account_id,
      gateway_name: Rails.application.config.gateway_name,
      gateway_display_name: Rails.application.config.gateway_display_name
    }
    args = {
      account_id: session['ds_account_id'],
      base_path: session['ds_base_path'],
      access_token: session['ds_access_token'],
      envelope_args: envelope_args
    }

    results = ESign::Eg014CollectPaymentService.new(args).worker
    @title = @example['ExampleName']
    @message = format_string(@example['ResultsPageText'], results[:envelope_id])
    render 'ds_common/example_done'
  rescue DocuSign_eSign::ApiError => e
    handle_error(e)
  end
end
