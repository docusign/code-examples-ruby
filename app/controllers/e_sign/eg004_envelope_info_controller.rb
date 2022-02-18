# frozen_string_literal: true

class ESign::Eg004EnvelopeInfoController < EgController
  before_action :check_auth

  def create
    envelope_id = session[:envelope_id]

    if envelope_id
      begin
        args = {
          account_id: session['ds_account_id'],
          base_path: session['ds_base_path'],
          access_token: session['ds_access_token'],
          envelope_id: envelope_id
        }
        results = ESign::Eg004EnvelopeInfoService.new(args).worker
        # results is an object that implements ArrayAccess. Convert to a regular array:
        @title = 'Envelope status results'
        @h1 = 'Envelope status results'
        @message = 'Results from the Envelopes::get method:'
        @json = results.to_json.to_json
        render 'ds_common/example_done'
      rescue  DocuSign_eSign::ApiError => e
        handle_error(e)
      end
    elsif !envelope_id
      @title = 'Envelope information'
      @envelope_ok = false
    end
  end
end
