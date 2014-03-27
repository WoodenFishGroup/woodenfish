require 'active_support/all'

module ApplicationHelper
  @current_user_sso = {}
  @current_user = nil

  def get_timezone_offset(zone)
    return 0 if zone.nil?
    if zone.downcase == 'cst'
      8.hours
    elsif zone.downcase == 'pst'
      -7.hours
    end
  end

  def is_mail_safe_image?(url)
    url.include?("http://www.gravatar.com/avatar/")
  end

  def set_current_user_sso(user_sso)
    @current_user_sso = user_sso
    user = User.query_or_create_user({"email" => user_sso["email"]})
    set_current_user(user)
  end

  def set_current_user(user)
    @current_user = user
  end

  def get_current_user_name
    if @current_user_sso
      "#{@current_user_sso["first_name"]} #{@current_user_sso["last_name"]}"
    else
      "unknown"
    end
  end

  def get_current_user_email
    if @current_user_sso
      @current_user_sso["email"]
    else
      ""
    end
  end

  def get_current_user_id
    if @current_user
      @current_user.id
    else
      nil
    end
  end

  def get_current_user_avartar
    @current_user ? @current_user.avartar : "http://www.gravatar.com/avatar/a"
  end

  def clear_current_user_and_sso
    @current_user_sso = {}
    @current_user = nil
  end

  def current_user
    @current_user
  end

end
