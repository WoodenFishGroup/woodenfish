class LoginController < ApplicationController
  before_filter :cms_hulu_sso_login
  before_filter :set_account

  private

  include HuluSSOLogin   
  include ApplicationHelper
  def cms_hulu_sso_login
    if not (params[:without_login] == "true")
      return hulu_sso_verify(:hijack_protection => false)
    end
  end
  
  def set_account
    set_current_user_sso(request.env['HULU_SSO']) if !request.env['HULU_SSO'].blank?
  end
end