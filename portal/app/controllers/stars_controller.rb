
class StarsController < LoginController
  def star_post
    @post_id = params[:post_id]
    @post = Post.where("id=#{@post_id}").first
    @post.change_star_status(get_current_user_id, params[:toggle] == "true")
    respond_to do |format|
      format.html
      format.js { @post.reload }
    end
  end
end
