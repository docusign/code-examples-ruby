# frozen_string_literal: true

class ESign::Eg015GetEnvelopeTabDataController < EgController
  before_action :check_auth

  def create
    envelope_id = session[:envelope_id]

    args = {
      access_token: session['ds_access_token'],
      base_path: session['ds_base_path'],
      account_id: session['ds_account_id'],
      envelope_id: envelope_id
    }

    results = ESign::Eg015GetEnvelopeTabDataService.new(args).worker
    @h1 = 'List envelopes results'
    @message = 'Results from the EnvelopeFormData::get method:'
    @json =  results.to_json.to_json
    render 'ds_common/example_done'
  end
end
