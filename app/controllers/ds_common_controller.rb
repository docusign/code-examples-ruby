# frozen_string_literal: true

class DsCommonController < ApplicationController
  # miscellaneous controllers
  #

  def index
    if Rails.configuration.examples_API == 'roomsAPI'
      render 'room_api/index'
    elsif Rails.configuration.examples_API == 'signature'
      @show_doc = Rails.application.config.documentation
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
    @title = 'Return from DocuSign'
    @event = request.params['event']
    @state = request.params['state']
    @envelope_id = request.params['envelopeId']
  end

  def ds_must_authenticate
    @title = 'Authenticate with DocuSign'
    if params[:auth] == 'grand-auth'
      redirect_to('/auth/docusign')
    elsif params[:auth] == 'jwt-auth'
      redirect_to root_path if session[:token].present?
      if Rails.configuration.examples_API == 'roomsAPI'
        configuration = DocuSign_Rooms::Configuration.new
        api_client = DocuSign_Rooms::ApiClient.new(configuration)
      elsif Rails.configuration.examples_API == 'signature'
        configuration = DocuSign_eSign::Configuration.new
        api_client = DocuSign_eSign::ApiClient.new(configuration)
      end
      resp = ::JwtAuth::JwtCreator.new(session, api_client).check_jwt_token
      if resp.is_a? String
        redirect_to resp
      end
    end
  end

  def example_done; end

  def error; end
end
