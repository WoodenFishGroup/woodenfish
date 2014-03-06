class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session
  # old: protect_from_forgery with: :exception
  skip_before_filter :verify_authenticity_token

  protected
  def info_has_all_values?(info, keys)
    (info.values_at(*keys).index {|v| v.nil? || v.empty?}).nil?
  end
end
