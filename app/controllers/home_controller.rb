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

  def edit_post
    @post_id = params[:post_id]
    @post = Post.find(params[:post_id])
    respond_to do |format|
      format.js
    end
  end

  def save_post
    post_id = params[:post_id]
    subject = params[:post_subject]
    body = params[:post_body]
    Post.update(post_id, :subject => subject, :body => body, :modified_by => get_current_user_id, :modified => Time.now.utc)
    @post = Post.find(post_id)
    redirect_to :action => 'index'
  end

  def star_post
    @post_id = params[:post_id]
    @post = Post.where("id=#{@post_id}").first
    Post.change_star_status(@post, get_current_user_id)
    Post.update(@post_id, :starred_by => @post.starred_by)
    respond_to do |format|
      format.js
    end
  end

  def health_check
  end
end
