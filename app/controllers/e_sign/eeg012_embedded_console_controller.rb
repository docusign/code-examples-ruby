# frozen_string_literal: true

class ESign::Eeg012EmbeddedConsoleController < EgController
  before_action -> { check_auth('eSignature') }
  before_action -> { @example = Utils::ManifestUtils.new.get_example(@manifest, 12, 'eSignature') }

  def create
    envelope_id = session[:envelope_id]

    begin
      args = {
        account_id: session['ds_account_id'],
        base_path: session['ds_base_path'],
        access_token: session['ds_access_token'],
        envelope_id: envelope_id,
        starting_view: params['starting_view'],
        ds_return_url: "#{Rails.application.config.app_url}/ds_common-return"
      }

      results = ESign::Eg012EmbeddedConsoleService.new(args).worker
      redirect_to results['redirect_url']
    rescue DocuSign_eSign::ApiError => e
      handle_error(e)
    end
  end
end
