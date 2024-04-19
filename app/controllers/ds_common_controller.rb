# frozen_string_literal: true

class DsCommonController < ApplicationController
  # miscellaneous controllers
  #

  def index
    @show_doc = Rails.application.config.documentation
    handle_redirects
  end

  def handle_redirects
    if Rails.configuration.quickstart
      @manifest = Utils::ManifestUtils.new.get_manifest(Rails.configuration.example_manifest_url)

      if session[:quickstarted].nil?
        session[:api] = 'eSignature'
        session[:quickstarted] = true
        redirect_to '/auth/docusign'
      elsif session[:been_here].nil?
        return redirect_to '/auth/docusign' if session[:ds_access_token].nil? || session[:ds_base_path].nil?

        enableCFR = ESign::GetDataService.new(session[:ds_access_token], session[:ds_base_path]).cfr?(session[:ds_account_id])
        if enableCFR == 'enabled'
          session[:status_cfr] = 'enabled'
          @status_cfr = session[:status_cfr]
          redirect_to '/eeg041'
        else
          redirect_to '/eeg001'
        end
      else
        render_examples
      end
    elsif check_token
      if !session[:api] || session[:api] == 'eSignature'
        enableCFR = ESign::GetDataService.new(session[:ds_access_token], session[:ds_base_path]).cfr?(session[:ds_account_id])
        session[:status_cfr] = 'enabled' if enableCFR == 'enabled'
      end
      render_examples
    else
      render_examples
    end
  end

  def render_examples
    if check_token && !session[:status_cfr] && (!session[:api] || session[:api] == 'eSignature')
      enableCFR = ESign::GetDataService.new(session[:ds_access_token], session[:ds_base_path]).cfr?(session[:ds_account_id])
      if enableCFR == 'enabled'
        @status_cfr = 'enabled'
        session[:status_cfr] = 'enabled'
      end
    else
      @status_cfr = session[:status_cfr]
    end
    load_manifest
  end

  def ds_return
    # To break out of the Quickstart loop an example has been completed
    session[:been_here] = true
    @title = 'Return from Docusign'
    @event = request.params['event']
    @state = request.params['state']
    @envelope_id = request.params['envelopeId']
  end

  def ds_must_authenticate
    load_manifest

    jwt_auth if session[:api] == 'Monitor'
    redirect_to '/auth/docusign' if Rails.configuration.quickstart && session[:been_here].nil?
    @title = 'Authenticate with Docusign'
    @show_doc = Rails.application.config.documentation

    case params[:auth]
    when 'grand-auth'
      redirect_to '/auth/docusign'
    when 'jwt-auth'
      jwt_auth
    end
  end

  def jwt_auth
    if JwtAuth::JwtCreator.new(session).check_jwt_token
      url = if session[:eg]
              "/#{session[:eg]}"
            else
              root_path
            end
    else
      session['omniauth.state'] = SecureRandom.hex
      url = JwtAuth::JwtCreator.consent_url(session['omniauth.state'], session['api'])
      redirect_to root_path if session[:token].present?
    end
    case session[:api]
    when 'Rooms'
      configuration = DocuSign_Rooms::Configuration.new
      DocuSign_Rooms::ApiClient.new(configuration)
    when 'Click'
      configuration = DocuSign_Click::Configuration.new
      DocuSign_Click::ApiClient.new configuration
    when 'Admin'
      configuration = DocuSign_Admin::Configuration.new
      DocuSign_Admin::ApiClient.new configuration
    end
    resp = ::JwtAuth::JwtCreator.new(session).check_jwt_token
    redirect_to resp if resp.is_a? String
    redirect_to url
  end

  def example_done; end

  def error; end

  private

  def load_manifest
    @manifest = Utils::ManifestUtils.new.get_manifest(Rails.configuration.example_manifest_url)
  end

  def check_token(buffer_in_min = 10)
    buffer = buffer_in_min * 60
    expires_at = session[:ds_expires_at]
    remaining_duration = expires_at.nil? ? 0 : expires_at - buffer.seconds.from_now.to_i
    remaining_duration.positive?
  end
end
