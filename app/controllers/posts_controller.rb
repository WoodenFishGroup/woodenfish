require 'json'
require 'resque'
require 'tasks/new_post_notification'

class PostsController < LoginController
  POSTS_PER_PAGE = 20
  def sample
    #post = Post.find_by_id(89)
    #NotificationMailer.new_post_notify(post).deliver
    #comment = Comment.find_by_id(47)
    #NotificationMailer.new_comment_notify(comment).deliver
    #user = User.find(1)
    #new_posts = Post.where("id>9").all[0..5]
    #new_comments = Comment.where("id>9").all.select {|c| !c.post.nil?} [0..5]
    #NotificationMailer.summary(user, new_posts, new_comments).deliver
  end

  def index
    if params[:post_id].to_i > 0 && Post.where("posts.id = ?", params[:post_id].to_i).count > 0
      count = Post.where("posts.id > ?", params[:post_id].to_i).count
      params[:page] = count / POSTS_PER_PAGE + 1
      @post_id = params[:post_id].to_i
    end
    @posts = Post.where("is_deleted=0")
        .includes(:user)
        .paginate(:page => params[:page], :per_page => POSTS_PER_PAGE)
        .order("posts.id DESC")
    render "list"
  end

  def stared
    @posts = current_user.stared_posts
      .where("is_deleted=0")
      .includes(:user)
      .includes(:stars)
      .paginate(:page => params[:page], :per_page => POSTS_PER_PAGE)
      .order("id DESC")
    @nav = "stared"
    render "list"
  end

  def edit
    @post_id = params[:post_id]
    @post = Post.find(params[:post_id])
    respond_to do |format|
      format.js
    end
  end

  def save
    post_id = params[:post_id]
    subject = params[:post_subject]
    body = params[:post_body]
    Post.update(post_id, :subject => subject, :body => body, :modified_by => get_current_user_id, :modified => Time.now.utc)
    @post = Post.find(post_id)
    redirect_to root_path
  end

  # NOTE: for easier debugging
  def portal_submit
    user_info = {"email" => params[:user_email]}
    post_info = {
        "subject" => params[:post_subject],
        "body" => params[:post_body],
        "source" => "portal",
        "source_id" => "post-#{Time.now.utc.to_i}@woodenfish.hulu.com"
    }
    feed_impl(user_info, post_info)
  end

  # NOTE: for easier debugging
  def add_notification
    post_id = params[:post_id]
    Resque.enqueue(Tasks::NewPostNotification, post_id)
    post = Post.find_by_id(post_id)
    render :json => post
  end

  # params should look like:
  # {
  #   :user => {
  #     :name => ...,
  #     :email => ...
  #   }, 
  #   :post => {
  #     :subject => ...,
  #     :body => ...,
  #     :source => ...,
  #     :source_id => ...
  #   }
  # }
  def create
    user_info = (params["user"] || {})
    post_info = {
      "source" => "portal",
      "source_id" => Time.now.utc.to_i.to_s
    }.merge(params["post"] || {})
    feed_impl(user_info, post_info)
  end

  private

  def feed_impl(user_info, post_info)
    assert_user_info(user_info)
    assert_post_info(post_info)
    user = User.query_or_create_user(user_info)
    post, create = Post.query_or_create_post(post_info, user)
    render :json => post
  end

  def assert_post_info(info)
    raise "wrong post info" if not info_has_all_values?(info, ["subject", "body", "source", "source_id"])
  end

  def assert_user_info(info)
    raise "wrong user info" if not info_has_all_values?(info, ["email"])
  end
end
