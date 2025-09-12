# frozen_string_literal: true

class Webforms::Weg002CreateRemoteInstanceController < EgController
  before_action -> { check_auth('WebForms') }
  before_action -> { @example = Utils::ManifestUtils.new.get_example(@manifest, 2, 'WebForms') }

  def create_web_form_template
    args = {
      template_name: 'Web Form Example Template',
      account_id: session[:ds_account_id],
      base_path: session[:ds_base_path],
      access_token: session[:ds_access_token]
    }

    begin
      web_form_template_id = Webforms::Eg002CreateRemoteInstanceService.new(args).create_web_form_template
      Utils::FileUtils.new.replace_template_id(File.join('data', Rails.application.config.web_form_config_file), web_form_template_id)
      session[:web_form_template_id] = web_form_template_id

      redirect_to '/weg002webForm'
    rescue DocuSign_eSign::ApiError => e
      handle_error(e)
    end
  end

  def create_web_form_instance
    args = {
      form_name: 'Web Form Example Template',
      account_id: session[:ds_account_id],
      base_path: Rails.application.config.webforms_host,
      signer_name: Rails.application.config.signer_name,
      signer_email: Rails.application.config.signer_email,
      access_token: session[:ds_access_token]
    }
    create_remote_instance_service = Webforms::Eg002CreateRemoteInstanceService.new(args)
    web_forms = create_remote_instance_service.list_web_forms

    if web_forms.items.nil? || web_forms.items.empty?
      @error_code = '404'
      @error_message = @example['CustomErrorTexts'][0]['ErrorMessage']
      return render 'ds_common/error'
    end
    results = create_remote_instance_service.create_web_form_instance web_forms.items.first.id

    @title = @example['ExampleName']
    @message = format_string(@example['ResultsPageText'], results.envelopes[0].id, results.id)
    render 'ds_common/example_done'
  end

  def get_web_form_create_view
    redirect_to '/weg002' if session[:web_form_template_id].nil?

    additional_page = @example['AdditionalPage'].find { |p| p['Name'] == 'create_web_form' }
    @title = @example['ExampleName']
    @description = format_string(additional_page['ResultsPageText'], 'data')

    render 'webforms/weg002_create_remote_instance/web_form_create'
  end
end
