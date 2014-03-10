class HomeController < LoginController

  def index
    @posts = Post.where("is_deleted=0").paginate(:page => params[:page], :per_page => 20).order("id DESC")
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
