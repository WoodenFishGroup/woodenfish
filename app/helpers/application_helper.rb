require 'utilities/data'

module ApplicationHelper
  include Utilities::Data

  @@current_user_sso = {}
  @@current_user = nil

  def set_current_user_sso(user_sso)
    @@current_user_sso = user_sso
    user = query_or_create_user({"email" => user_sso["email"]})
    set_current_user(user)
  end

  def set_current_user(user)
    @@current_user = user
  end

  def get_current_user_name
    "#{@@current_user_sso["first_name"]} #{@@current_user_sso["last_name"]}"
  end

  def get_current_user_email
    @@current_user_sso["email"]
  end

  def get_current_user_id
    @@current_user.id
  end

  def get_current_user_avartar
    @@current_user ? @@current_user.avartar : "http://www.gravatar.com/avatar/a"
  end

end
