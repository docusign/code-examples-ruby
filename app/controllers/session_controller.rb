class SessionController < ApplicationController

  def create
    # reset the session
    internal_destroy

    # populate the session
    userinfo = request.env['omniauth.auth']
    info = userinfo.info
    cred = userinfo.credentials
    session[:ds_expires_at] = userinfo.credentials['expires_at']
    session[:ds_user_name] = info.name
    session[:ds_access_token] = cred.token
    session[:ds_account_id] = userinfo.extra.account_id
    session[:ds_account_name] = userinfo.extra.account_name
    session[:ds_base_path] = userinfo.extra.base_uri
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
    request.env['omniauth.auth']
  end
end