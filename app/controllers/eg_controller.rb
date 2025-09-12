# frozen_string_literal: true

class EgController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :eg_name, :set_eg, :set_meta, :ensure_manifest

  def file_name
    "#{controller_path}_service.rb"
  end

  def eg_name
    controller_name.to(4)
  end

  def set_eg
    session[:eg] = controller_name.split('_', 2).first
  end

  def get
    @messages = ''

    # to have the user authenticate or re-authenticate.
    @token_ok = check_token
    @config = Rails.application.config
    if @token_ok || controller_name.include?('cneg')
      # addSpecialAttributes(model)
      @envelope_ok = session[:envelope_id].present?
      @documents_ok = session[:envelope_documents].present?
      @document_options = session.fetch(:envelope_documents, {})['documents']
      @gateway_ok = @config.gateway_account_id.try(:length) > 25
      @template_ok = session[:template_id].present?
      @documentation = "#{@config.documentation}#{eg_name}" #= Config.documentation + EgName
      @show_doc = @config.documentation
    else
      redirect_to '/ds/mustAuthenticate'
    end
  end

  def set_meta
    @source_file = file_name.to_s
    #remove extra character that doesn't exist in service file
    index = @source_file.index('/')
    @source_file = index.nil? ? @source_file.sub(/^.*?eg/, 'eg') : @source_file.sub(%r{/.+?eg}, '/eg')
    @source_url = "#{Rails.application.config.github_example_url}#{@source_file}"
  end

  def check_token(buffer_in_min = 10)
    buffer = buffer_in_min * 60
    expires_at = session[:ds_expires_at]
    remaining_duration = expires_at.nil? ? 0 : expires_at - buffer.seconds.from_now.to_i
    if expires_at.nil?
      Rails.logger.info '==> Token expiration is not available: fetching token'
    elsif remaining_duration.negative?
      Rails.logger.debug "==> Token is about to expire in #{time_in_words(remaining_duration)} at: #{Time.at(expires_at)}: fetching token"
    else
      Rails.logger.debug "==> Token is OK for #{time_in_words(remaining_duration)} at: #{Time.at(expires_at)}"
    end
    remaining_duration.positive?
  end

  private

  def time_in_words(duration)
    "#{Object.new.extend(ActionView::Helpers::DateHelper).distance_of_time_in_words(duration)}#{duration.negative? ? ' ago' : ''}"
  end

  def param_gsub(parameter)
    parameter.gsub(/([^\w \-@.,])+/, '')
  end

  def check_auth(api)
    # if not authorized for same API type example or
    # if it is an attempt to authorize from home page
    # then user will be redirected to login page
    unless (session[:api] == api) || ((api == 'eSignature') && !session[:api])
      session[:api] = api
      params[:auth] = 'jwt-auth' if api == 'Monitor'

      return redirect_to '/ds/mustAuthenticate'
    end

    minimum_buffer_min = 10
    token_ok = check_token(minimum_buffer_min)
    return if token_ok

    flash[:messages] = 'Sorry, you need to re-authenticate.'
    # We could store the parameters of the requested operation so it could be restarted automatically
    # But since it should be rare to have a token issue here, we'll make the user re-enter the form data after authentication
    redirect_to '/ds/mustAuthenticate'
  end

  def handle_error(e)
    error = JSON.parse e.response_body
    @error_code = e.code || error['errorCode']
    @error_message = error['error_description'] || error['message'] || error['error']
    render 'ds_common/error'
  end

  def create_source_path
    # code here
  end

  def ensure_manifest
    @manifest = Utils::ManifestUtils.new.get_manifest(Rails.configuration.example_manifest_url)
  end

  def format_string(string, *args)
    string.gsub(/\{(\d+)\}/) { args[::Regexp.last_match(1).to_i] }
  end
end
