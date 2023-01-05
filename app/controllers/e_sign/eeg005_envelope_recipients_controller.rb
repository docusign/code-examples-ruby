# frozen_string_literal: true

class ESign::Eeg005EnvelopeRecipientsController < EgController
  include ApiCreator
  before_action -> { check_auth('eSignature') }
  before_action -> { @example = Utils::ManifestUtils.new.get_example(@manifest, 5, 'eSignature') }
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
        @title = @example['ExampleName']
        @message = 'Results from the EnvelopesRecipients::list method:'
        @json = results.to_json.to_json
        render 'ds_common/example_done'
      rescue DocuSign_eSign::ApiError => e
        handle_error(e)
      end
    elsif !envelope_id
      @title = @example['ExampleName']
      @envelope_ok = false
    end
  end
end
