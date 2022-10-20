# frozen_string_literal: true

class ESign::Eg018GetEnvelopeCustomFieldDataController < EgController
  before_action :check_auth
  before_action -> { @example = Utils::ManifestUtils.new.get_example(@manifest, 18) }

  def create
    envelope_id = session[:envelope_id]

    args = {
      access_token: session['ds_access_token'],
      base_path: session['ds_base_path'],
      account_id: session['ds_account_id'],
      envelope_id: envelope_id
    }

    results = ESign::Eg018GetEnvelopeCustomFieldDataService.new(args).worker
    @title = @example['ExampleName']
    @message = 'Results from the Envelopes::listStatusChanges method:'
    @json =  results.to_json.to_json
    render 'ds_common/example_done'
  end
end
