# frozen_string_literal: true

class ESign::Eeg008CreateTemplateController < EgController
  before_action -> { check_auth('eSignature') }
  before_action -> { @example = Utils::ManifestUtils.new.get_example(@manifest, 8, 'eSignature') }

  def create
    args = {
      account_id: session['ds_account_id'],
      base_path: session['ds_base_path'],
      access_token: session['ds_access_token'],
      template_name: 'Example Signer and CC template v2'
    }
    results = ESign::Eg008CreateTemplateService.new(args).worker
    session[:template_id] = results[:template_id]
    session[:workflow_template_id] = results[:template_id]
    msg = if results.fetch(:created_new_template)
            'The template has been created!'
          else
            'Done. The template already existed in your account.'
          end
    @title = @example['ExampleName']
    @message = "#{msg} #{format_string(@example['ResultsPageText'], results[:template_name], results[:template_id])}"
    render 'ds_common/example_done'
  rescue DocuSign_eSign::ApiError => e
    handle_error(e)
  end
end
