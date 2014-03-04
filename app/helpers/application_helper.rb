module ApplicationHelper
  def set_current_user(user)
    @@current_user = user
  end

  def get_current_user
    @@current_user
  end

  def get_current_user_name
    "#{@@current_user["first_name"]} #{@@current_user["last_name"]}"
  end

  def get_current_user_email
    @@current_user["email"]
  end

end
