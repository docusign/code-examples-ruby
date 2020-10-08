# frozen_string_literal: true

class EgController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :file_name, :eg_name

  def file_name
    File.basename __FILE__
  end

  def eg_name
    controller_name.to(4)
  end

  def get
    @messages = ''

    # to have the user authenticate or re-authenticate.
    @token_ok = check_token
    @config = Rails.application.config
    if @token_ok
      # addSpecialAttributes(model)
      @envelope_ok = session[:envelope_id].present?
      @documents_ok = session[:envelope_documents].present?
      @document_options = session.fetch(:envelope_documents, {})['documents']
      @gateway_ok = @config.gateway_account_id.try(:length) > 25
      @template_ok = session[:template_id].present?
      @source_file = file_name.to_s
      @source_url = "#{@config.github_example_url}#{@source_file}"
      @documentation = "#{@config.documentation}#{eg_name}" #= Config.documentation + EgName
      @show_doc = @config.documentation
    elsif @config.quickstart == true

      redirect_to '/ds/login'

    else
      # RequestItemsService.EgName = EgName
      redirect_to '/ds/mustAuthenticate'
    end
  end

  private

  def check_token(buffer_in_min = 10)
    buffer = buffer_in_min * 60
    expires_at = session[:ds_expires_at]
    now = Time.now.to_f # seconds since epoch
    remaining_duration = expires_at.nil? ? 0 : (expires_at - (now + buffer))
    if expires_at.nil?
      Rails.logger.info "==> Token expiration is not available: fetching token"
    elsif remaining_duration.negative?
      Rails.logger.debug "==> Token is about to expire in #{time_in_words(remaining_duration)} at: #{Time.at(expires_at)}: fetching token"
    else
      Rails.logger.debug "==> Token is OK for #{time_in_words(remaining_duration)} at: #{Time.at(expires_at)}"
    end
    remaining_duration > 0
  end

  def time_in_words(duration)
    "#{Object.new.extend(ActionView::Helpers::DateHelper).distance_of_time_in_words(duration)}#{duration.negative? ? ' ago' : ''}"
  end

  def create_source_path
    # code here
  end
end
