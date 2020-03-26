# frozen_string_literal: true

class DsCommonController < ApplicationController
  # miscellaneous controllers
  #

  def index
    @show_doc = Rails.application.config.documentation
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
  end

  def example_done; end

  def error; end
end
