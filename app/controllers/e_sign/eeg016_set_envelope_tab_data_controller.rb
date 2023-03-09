# frozen_string_literal: true

class ESign::Eeg016SetEnvelopeTabDataController < EgController
  before_action -> { check_auth('eSignature') }
  before_action -> { @example = Utils::ManifestUtils.new.get_example(@manifest, 16, 'eSignature') }

  def create
    args = {
      # Validation: Delete any non-usual characters
      signer_email: params['signerEmail'].gsub(/([^\w\-.+@, ])+/, ''),
      signer_name: params['signerName'].gsub(/([^\w\-., ])+/, ''),
      access_token: session['ds_access_token'],
      base_path: session['ds_base_path'],
      account_id: session['ds_account_id']
    }

    begin
      results = ESign::Eg016SetEnvelopeTabDataService.new(args).worker

      # Save for future use within the example launcher
      session[:envelope_id] = results[:envelope_id]

      redirect_to results[:url]
    rescue DocuSign_eSign::ApiError => e
      handle_error(e)
    end
  end
end
