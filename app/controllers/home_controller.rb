class HomeController < LoginController

  def save_profile
    avartar = params[:avartar]
    User.update(get_current_user_id, :avartar => avartar)
    redirect_to root_path
  end

end
