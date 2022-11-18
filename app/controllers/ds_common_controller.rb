# frozen_string_literal: true

class DsCommonController < ApplicationController
  # miscellaneous controllers
  #

  def index
    @show_doc = Rails.application.config.documentation
    handle_redirects
  end

  def handle_redirects
    minimum_buffer_min = 10
    if Rails.configuration.quickstart
      @manifest = Utils::ManifestUtils.new.get_manifest(Rails.configuration.eSignManifestUrl)

      if session[:quickstarted].nil?
        session[:examples_API] = 'eSignature'
        session[:quickstarted] = true
        redirect_to '/auth/docusign'
      elsif session[:been_here].nil?
        enableCFR = ESign::GetDataService.new(session[:ds_access_token], session[:ds_base_path]).is_cfr(session[:ds_account_id])
        if enableCFR == "enabled"
          session[:status_cfr] = "enabled"
          redirect_to '/eg041'
        else
          redirect_to '/eg001'
        end
      else
        render_examples
      end
    elsif session[:ds_access_token].present?
      enableCFR = ESign::GetDataService.new(session[:ds_access_token], session[:ds_base_path]).is_cfr(session[:ds_account_id])
      if enableCFR == "enabled"
        session[:status_cfr] = "enabled"
      end
      render_examples
    else
      render_examples
    end
  end

  def render_examples
    load_corresponding_manifest

    if session[:examples_API].nil?
      choose_api
    elsif session[:examples_API] == 'Rooms'
      render 'room_api/index'
    elsif session[:examples_API] == 'Click'
      render 'clickwrap/index'
    elsif session[:examples_API] == 'Monitor'
      render 'monitor_api/index'
    elsif session[:examples_API] == 'Admin'
      render 'admin_api/index'
    else
      @status_cfr = session[:status_cfr]
      session[:examples_API] = 'eSignature'
      render 'ds_common/index'
    end
  end

  def choose_api
    load_corresponding_manifest
    render 'ds_common/choose_api'
  end

  def api_selected
    session.delete :eg
    session[:examples_API] = params[:chosen_api]
    redirect_to '/ds/mustAuthenticate'
  end

  def ds_return
    # To break out of the Quickstart loop an example has been completed
    session[:been_here] = true
    @title = 'Return from DocuSign'
    @event = request.params['event']
    @state = request.params['state']
    @envelope_id = request.params['envelopeId']
  end

  def ds_must_authenticate
    load_corresponding_manifest

    jwt_auth if session[:examples_API] == 'Monitor'
    redirect_to '/auth/docusign' if Rails.configuration.quickstart && session[:been_here].nil? && (session[:examples_API] == 'eSignature')
    @title = 'Authenticate with DocuSign'
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
      url = JwtAuth::JwtCreator.consent_url(session['omniauth.state'], session['examples_API'])
      redirect_to root_path if session[:token].present?
    end
    case session[:examples_API]
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

  def load_corresponding_manifest
    manifest_url = if session[:examples_API].nil?
                     Rails.configuration.eSignManifestUrl
                   elsif session[:examples_API] == 'Rooms'
                     Rails.configuration.roomsManifestUrl
                   elsif session[:examples_API] == 'Click'
                     Rails.configuration.clickManifestUrl
                   elsif session[:examples_API] == 'Monitor'
                     Rails.configuration.monitorManifestUrl
                   elsif session[:examples_API] == 'Admin'
                     Rails.configuration.adminManifestUrl
                   else
                     Rails.configuration.eSignManifestUrl
                   end

    @manifest = Utils::ManifestUtils.new.get_manifest(manifest_url)
  end
end
