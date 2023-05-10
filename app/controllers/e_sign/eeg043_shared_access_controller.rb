# frozen_string_literal: true

require_relative '../../services/utils'

class ESign::Eeg043SharedAccessController < EgController
  before_action :authenticate_agent, only: [:list_envelopes]
  before_action -> { check_auth('eSignature') }, except: %i[reauthenticate list_envelopes]
  before_action -> { @example = Utils::ManifestUtils.new.get_example(@manifest, 43, 'eSignature') }

  def create_agent
    args = {
      account_id: session['ds_account_id'],
      base_path: session['ds_base_path'],
      access_token: session['ds_access_token'],
      email: params['email'],
      user_name: param_gsub(params['user_name']),
      activation: param_gsub(params['activation'])
    }
    results = ESign::Eg043SharedAccessService.new(args).create_agent
    session[:agent_user_id] = results.user_id
    @title = @example['ExampleName']
    @message = @example['ResultsPageText']
    @json = results.to_json.to_json
    @redirect_url = '/eeg043auth'
    render 'ds_common/example_done'
  rescue DocuSign_eSign::ApiError => e
    handle_error(e)
  end

  def create_authorization
    args = {
      account_id: session['ds_account_id'],
      base_path: session['ds_base_path'],
      access_token: session['ds_access_token'],
      agent_user_id: session['agent_user_id']
    }
    args[:user_id] = Utils::DocuSignUtils.new.get_user_id args
    session[:principal_user_id] = args[:user_id]

    ESign::Eg043SharedAccessService.new(args).create_authorization

    additional_page_data = @example['AdditionalPage'].find { |p| p['Name'] == 'authenticate_as_agent' }
    @title = 'Authenticate as the agent'
    @message = additional_page_data['ResultsPageText']
    @redirect_url = '/eeg043reauthenticate'
    render 'ds_common/example_done'
  rescue DocuSign_eSign::ApiError => e
    error = JSON.parse e.response_body
    if error['errorCode'] == 'USER_NOT_FOUND'
      additional_page_data = @example['AdditionalPage'].find { |p| p['Name'] == 'user_not_found' }
      @title = 'Authenticate as the agent'
      @message = additional_page_data['ResultsPageText']
      @redirect_url = '/eeg043auth'
      return render 'ds_common/example_done'
    end
    handle_error(e)
  end

  def reauthenticate
    logout
    redirect_to '/eeg043envelopes'
  end

  def list_envelopes
    args = {
      account_id: session['ds_account_id'],
      base_path: session['ds_base_path'],
      access_token: session['ds_access_token'],
      user_id: session[:principal_user_id]
    }
    results = ESign::Eg043SharedAccessService.new(args).get_envelopes

    if results.result_set_size.to_i.positive?
      additional_page_data = @example['AdditionalPage'].find { |p| p['Name'] == 'list_status_successful' }
      @title = "Principal's envelopes visible in the agent's Shared Access UI"
      @json = results.to_json.to_json
    else
      additional_page_data = @example['AdditionalPage'].find { |p| p['Name'] == 'list_status_unsuccessful' }
      @title = "No envelopes in the principal user's account"
    end

    @message = additional_page_data['ResultsPageText']
    render 'ds_common/example_done'
  rescue DocuSign_eSign::ApiError => e
    handle_error(e)
  end

  private

  def logout
    session.delete :ds_access_token
    session.delete :ds_account_id
    session.delete :ds_expires_at
    session.delete 'omniauth.state'
    session.delete 'omniauth.params'
    session.delete 'omniauth.origin'
  end

  def authenticate_agent
    minimum_buffer_min = 10
    token_ok = check_token(minimum_buffer_min)
    return if token_ok

    session[:eg] = 'eeg043envelopes'
    redirect_to '/ds/mustAuthenticate'
  end
end
