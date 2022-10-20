# frozen_string_literal: true

class ESign::Eg017SetTemplateTabValuesController < EgController
  before_action :check_auth
  before_action -> { @example = Utils::ManifestUtils.new.get_example(@manifest, 17) }

  def create
    template_id = session[:template_id]

    if template_id
      envelope_args = {
        signer_email: params['signerEmail'],
        signer_name: params['signerName'],
        cc_email: params['ccEmail'],
        cc_name: params['ccName'],
        template_id: template_id
      }
      args = {
        account_id: session['ds_account_id'],
        base_path: session['ds_base_path'],
        access_token: session['ds_access_token'],
        envelope_args: envelope_args
      }

      redirect_url = ESign::Eg017SetTemplateTabValuesService.new(args).worker
      redirect_to redirect_url
    elsif !template_id
      @title = @example['ExampleName']
      @template_ok = false
    end
  end
end
