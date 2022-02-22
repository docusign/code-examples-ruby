# frozen_string_literal: true

class ESign::Eg005EnvelopeRecipientsController < EgController
  include ApiCreator
  before_action :check_auth
  skip_before_action :set_meta

  def create
    envelope_id = session[:envelope_id] || nil

    if envelope_id
      # 2. Call the worker method
      args = {
        account_id: session['ds_account_id'],
        base_path: session['ds_base_path'],
        access_token: session['ds_access_token'],
        envelope_id: envelope_id
      }

      begin
        results = ESign::Eg005EnvelopeRecipientsService.new(args).worker
        @title = 'Envelope recipients results'
        @h1 = 'List the envelope\'s recipients and their status'
        @message = 'Results from the EnvelopesRecipients::list method:'
        @json = results.to_json.to_json
        render 'ds_common/example_done'
      rescue  DocuSign_eSign::ApiError => e
        handle_error(e)
      end
    elsif !envelope_id
      @title = 'Envelope recipient information'
      @envelope_ok = false
    end
  end
end
