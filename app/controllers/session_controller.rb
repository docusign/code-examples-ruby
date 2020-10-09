# frozen_string_literal: true

class SessionController < ApplicationController
  def create
    # reset the session
    internal_destroy

    Rails.logger.debug "\n==> DocuSign callback Authentication response:\n#{auth_hash.to_yaml}\n"
    Rails.logger.info "==> Login: New token for admin user which will expire at: #{Time.at(auth_hash.credentials['expires_at'])}"
    # populate the session
    session[:ds_expires_at]   = auth_hash.credentials['expires_at']
    session[:ds_user_name]    = auth_hash.info.name
    session[:ds_access_token] = auth_hash.credentials.token
    session[:ds_account_id]   = auth_hash.extra.account_id
    session[:ds_account_name] = auth_hash.extra.account_name
    session[:ds_base_path]    = auth_hash.extra.base_uri
    redirect_to root_path
  end

  def destroy
    internal_destroy
    redirect_to root_path
  end

  protected

  def internal_destroy
    session.delete :ds_expires_at
    session.delete :ds_user_name
    session.delete :ds_access_token
    session.delete :ds_account_id
    session.delete :ds_account_name
    session.delete :ds_base_path
    session.delete :envelope_id
    session.delete :envelope_documents
    session.delete :template_id
  end

  def auth_hash
    @auth_hash ||= request.env['omniauth.auth']
  end
end
