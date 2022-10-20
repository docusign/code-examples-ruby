# frozen_string_literal: true

class ESign::Eg016SetEnvelopeTabDataController < EgController
  before_action :check_auth
  before_action -> { @example = Utils::ManifestUtils.new.get_example(@manifest, 16) }

  def create
    args = {
      # Validation: Delete any non-usual characters
      signer_email: params['signerEmail'].gsub(/([^\w\-.+@, ])+/, ''),
      signer_name: params['signerName'].gsub(/([^\w\-., ])+/, ''),
      access_token: session['ds_access_token'],
      base_path: session['ds_base_path'],
      account_id: session['ds_account_id']
    }

    results = ESign::Eg016SetEnvelopeTabDataService.new(args).worker

    # Save for future use within the example launcher
    session[:envelope_id] = results[:envelope_id]

    redirect_to results[:url]
  end
end
