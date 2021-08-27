# frozen_string_literal: true

class DsCommonController < ApplicationController
  # miscellaneous controllers
  #

  def index
    @show_doc = Rails.application.config.documentation
    if Rails.configuration.examples_API['Rooms']
      render 'room_api/index'
    elsif Rails.configuration.examples_API['Click']
      render 'clickwrap/index'
    elsif Rails.configuration.examples_API['Monitor']
      render 'monitor_api/index'
    elsif Rails.configuration.examples_API['Admin']
      render 'admin_api/index'
    else
      @show_doc = Rails.application.config.documentation
      if Rails.configuration.quickstart && session[:been_here].nil?
        redirect_to '/eg001'
      end
    end
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
    if Rails.configuration.examples_API['Monitor']
      jwt_auth
    end
    if Rails.configuration.quickstart
      redirect_to('/auth/docusign')
    end
    @title = 'Authenticate with DocuSign'
    @show_doc = Rails.application.config.documentation

    if params[:auth] == 'grand-auth'
      redirect_to('/auth/docusign')
    elsif params[:auth] == 'jwt-auth'
      jwt_auth
    end
  end

  def jwt_auth
    if JwtAuth::JwtCreator.new(session).check_jwt_token
      if session[:eg]
        url = "/" + session[:eg]
      else
        url = root_path
      end
    else
      session['omniauth.state'] = SecureRandom.hex
      url = JwtAuth::JwtCreator.consent_url(session['omniauth.state'])
    redirect_to root_path if session[:token].present?
    end
    if Rails.configuration.examples_API['Rooms']
      configuration = DocuSign_Rooms::Configuration.new
      api_client = DocuSign_Rooms::ApiClient.new(configuration)
    elsif Rails.configuration.examples_API['Click']
      configuration = DocuSign_Click::Configuration.new
      api_client = DocuSign_Click::ApiClient.new configuration
    elsif Rails.configuration.examples_API['Admin']
      configuration = DocuSign_Admin::Configuration.new
      api_client = DocuSign_Admin::ApiClient.new configuration
    end
    resp = ::JwtAuth::JwtCreator.new(session).check_jwt_token
    if resp.is_a? String
      redirect_to resp
    end
    redirect_to url
  end

  def example_done; end

  def error; end

end
