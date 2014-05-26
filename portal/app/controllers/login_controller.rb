class LoginController < ApplicationController
  before_filter :check_login
  before_filter :set_account

  private

  include ApplicationHelper
  def check_login
    if not (params[:without_login] == "true")
      # TODO complete login logic
      return true
    end
  end
  
  def set_account
    set_current_user_sso(request.env['HULU_SSO']) if !request.env['HULU_SSO'].blank?
  end
end
