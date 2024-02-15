# frozen_string_literal: true

class Webforms::Weg001CreateInstanceController < EgController
  before_action -> { check_auth('WebForms') }
  before_action -> { @example = Utils::ManifestUtils.new.get_example(@manifest, 1, 'WebForms') }

  def create_web_form_template
    args = {
      template_name: 'Web Form Example Template',
      account_id: session[:ds_account_id],
      base_path: session[:ds_base_path],
      access_token: session[:ds_access_token]
    }

    web_form_template_id = Webforms::Eg001CreateInstanceService.new(args).create_web_form_template
    Utils::FileUtils.new.replace_template_id(File.join('data', Rails.application.config.web_form_config_file), web_form_template_id)
    session[:web_form_template_id] = web_form_template_id

    redirect_to '/weg001webForm'
  end

  def create_web_form_instance
    args = {
      form_name: 'Web Form Example Template',
      client_user_id: '1234-5678-abcd-ijkl',
      account_id: session[:ds_account_id],
      base_path: Rails.application.config.webforms_host,
      access_token: session[:ds_access_token]
    }
    create_instance_service = Webforms::Eg001CreateInstanceService.new(args)
    web_forms = create_instance_service.list_web_forms
    results = create_instance_service.create_web_form_instance web_forms.items.first.id

    @integration_key = Rails.application.config.integration_key
    @form_url = results.form_url
    @instance_token = results.instance_token
    render 'webforms/weg001_create_instance/web_form_embed'
  end

  def get
    additional_page = @example['AdditionalPage'].find { |p| p['Name'] == 'create_web_form_template' }
    @example['ExampleDescription'] = additional_page['ResultsPageText']

    render 'webforms/weg001_create_instance/get'
  end

  def get_web_form_create_view
    redirect_to '/weg001' if session[:web_form_template_id].nil?

    additional_page = @example['AdditionalPage'].find { |p| p['Name'] == 'create_web_form' }
    @title = @example['ExampleName']
    @description = additional_page['ResultsPageText']

    render 'webforms/weg001_create_instance/web_form_create'
  end
end
