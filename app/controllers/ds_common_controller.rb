# frozen_string_literal: true

class DsCommonController < ApplicationController
  # miscellaneous controllers
  #

  def index
    @show_doc = Rails.application.config.documentation
    if Rails.configuration.quickstart == true && session[:been_here].nil?
      redirect_to '/eg001'
    end
  end

  def login
    redirect_to('/oauth/docusign')
  end

  def callback
    auth = request.env['omniauth.auth']
    render json: auth.to_json
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
    
    if Rails.configuration.quickstart == "true"
      redirect_to('auth/docusign')
    end
    @title = 'Authenticate with DocuSign'
    configuration = DocuSign_eSign::Configuration.new
    api_client = DocuSign_eSign::ApiClient.new(configuration)
    @show_doc = Rails.application.config.documentation

    if params[:auth] == 'grand-auth'
      redirect_to('/auth/docusign')
    elsif params[:auth] == 'jwt-auth'
      redirect_to root_path if session[:token].present?
      resp = ::JwtAuth::JwtCreator.new(session, api_client).check_jwt_token
      if resp.is_a? String
        redirect_to resp
      end
    end
    end
  end


  def example_done; end

  def error; end

