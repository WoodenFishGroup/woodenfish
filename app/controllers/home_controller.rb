class HomeController < LoginController

  def index
    @posts = Post.where("is_deleted=0").paginate(
        :page => params[:page], :per_page => 20).order("id DESC")
  end

  def save_profile
    avartar = params[:avartar]
    User.update(get_current_user_id, :avartar => avartar)
    redirect_to :action => 'index'
  end

end
