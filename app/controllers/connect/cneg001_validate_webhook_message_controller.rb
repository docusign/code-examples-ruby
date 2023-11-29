# frozen_string_literal: true

require_relative '../../services/utils'

class Connect::Cneg001ValidateWebhookMessageController < EgController
  before_action -> { @example = Utils::ManifestUtils.new.get_example(@manifest, 1, 'Connect') }

  def create
    args = {
      secret: params['secret'],
      payload: params['payload']
    }
    results = Connect::Eg001ValidateWebhookMessageService.new(args).worker
    @title = @example['ExampleName']
    @message = format_string(@example['ResultsPageText'], results)
    render 'ds_common/example_done'
  rescue DocuSign_eSign::ApiError => e
    handle_error(e)
  end
end
