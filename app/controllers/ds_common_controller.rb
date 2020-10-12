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
    @show_doc = Rails.application.config.documentation

    if params[:auth] == 'grand-auth'
      redirect_to('/auth/docusign')
    elsif params[:auth] == 'jwt-auth'
      if JwtAuth::JwtCreator.new(session).check_jwt_token
        url = root_path
      else
        url = JwtAuth::JwtCreator.consent_url
      end
      redirect_to url
    end
  end

  def example_done; end

  def error; end

end
