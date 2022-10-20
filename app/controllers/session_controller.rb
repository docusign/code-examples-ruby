# frozen_string_literal: true

class SessionController < ApplicationController
  # GET /auth/:provider/callback
  def create
    redirect_url = if session[:eg]
                     "/#{session[:eg]}"
                   else
                     root_path
                   end

    # reset the session
    internal_destroy

    Rails.logger.debug "\n==> DocuSign callback Authentication response:\n#{auth_hash.to_yaml}\n"
    Rails.logger.info "==> Login: New token for admin user which will expire at: #{Time.at(auth_hash.credentials['expires_at'])}"
    store_auth_hash_from_docusign_callback
    redirect_to redirect_url
  end

  # GET /ds/logout
  def destroy
    internal_destroy
    redirect_to root_path
  end

  # def switch_api
  #   internal_destroy
  # end

  # GET /auth/failure
  def omniauth_failure
    error_msg = "OmniAuth authentication failure message: #{params[:message]} for strategy: #{params[:strategy]} and HTTP_REFERER: #{params[:origin]}"
    Rails.logger.warn "\n==> #{error_msg}"
    flash[:notice] = error_msg
    redirect_to root_path
  end

  def show
    Rails.logger.debug "==> Session:\n#{session.to_h.to_yaml}"
    render json: session.to_json
  end

  protected

  def internal_destroy
    session.delete :ds_expires_at
    session.delete :ds_user_name
    session.delete :ds_access_token
    session.delete :ds_account_id
    session.delete :ds_account_name
    session.delete :ds_base_path
    session.delete 'omniauth.state'
    session.delete 'omniauth.params'
    session.delete 'omniauth.origin'
    session.delete :envelope_id
    session.delete :envelope_documents
    session.delete :template_id
    session.delete :eg
    session.delete :manifest
  end

  def store_auth_hash_from_docusign_callback
    session[:ds_expires_at]   = auth_hash.credentials['expires_at']
    session[:ds_user_name]    = auth_hash.info.name
    session[:ds_access_token] = auth_hash.credentials.token
    session[:ds_account_id]   = auth_hash.extra.account_id
    session[:ds_account_name] = auth_hash.extra.account_name
    session[:ds_base_path]    = auth_hash.extra.base_uri
  end

  # returns hash with key structure of:
  # - provider
  # - uid
  # - info: [name, email, first_name, last_name]
  # - credentials: [token, refresh_token, expires_at, expires]
  # - extra: [sub, account_id, account_name, base_uri]
  def auth_hash
    @auth_hash ||= request.env['omniauth.auth']
  end
end
