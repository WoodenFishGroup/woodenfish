class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session
  # old: protect_from_forgery with: :exception

  before_filter :cms_hulu_sso_login
  before_filter :set_account

  private

  include HuluSSOLogin   
  include ApplicationHelper
  def cms_hulu_sso_login
    return hulu_sso_verify(:hijack_protection => false)
  end
  
  def set_account
    set_current_user(request.env['HULU_SSO'])
  end
end
