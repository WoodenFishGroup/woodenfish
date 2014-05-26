class LoginController < ApplicationController
  # TODO support 'without_login' == true
  before_action :authenticate_user!
end
