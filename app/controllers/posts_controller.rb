# encoding: utf-8
require 'json'
require 'resque'
require 'tasks/new_post_notification'
require 'will_paginate/array'

class PostsController < LoginController
  POSTS_PER_PAGE = 20
  def sample
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

  def search
    q = params[:q].to_s.gsub(/[^\p{Word}]/, ' ')
    _find_by_ids = proc do |ids|
        Post.where(:id => ids).order("FIELD(id, #{ids.join ','})")
        .includes([:user, :stars])
      end
    ids = Post.select("id, MATCH(subject,body) AGAINST('#{q}') AS score")
      .where("MATCH(subject,body) AGAINST('#{q}')").order('score DESC').map(&:id)
    @posts = if ids.size > 0
        _find_by_ids.call ids
      else
        Post.where("(subject LIKE '%#{q}%' OR body LIKE'%#{q}%')").order('id DESC')
        .includes([:user, :stars])
      end
    ids_by_user = Post.select('id')
      .where("user_id IN (SELECT id FROM users WHERE name LIKE '%#{q}%')")
      .order('id DESC').map(&:id)
    if ids_by_user.size > 0
      @posts = (_find_by_ids.call(ids_by_user) + @posts).uniq(&:id)
    end
    @posts = @posts.to_a.reject { |p| p.is_deleted }
    @posts = @posts.paginate(:page => params[:page], :per_page => POSTS_PER_PAGE)
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
    if params[:commit] != 'cancel'
      post_id = params[:post_id]
      subject = params[:post_subject]
      body = params[:post_body]
      Post.update(post_id, :subject => subject, :body => body, :modified_by => get_current_user_id, :modified => Time.now.utc)
      #@post = Post.find(post_id)
      if params[:notify] == '1'
        Resque.enqueue(Tasks::NewPostNotification, post_id)
      end
    end
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
    user_info["email"] = params["user_email"] if params["user_email"]
    post_info = {
      "source" => "portal",
      "source_id" => "post-#{Time.now.utc.to_i.to_s}@woodenfish.hulu.com"
    }.merge(params["post"] || {})
    post_info["subject"] = params["post_subject"] if params["post_subject"]
    post_info["body"] = params["post_body"] if params["post_body"]
    feed_impl(user_info, post_info)
  end

  private

  def feed_impl(user_info, post_info)
    assert_user_info(user_info)
    assert_post_info(post_info)
    user = User.query_or_create_user(user_info)
    post, create = Post.query_or_create_post(post_info, user)
    if post_info["source"] == "portal"
      redirect_to root_path + "?post_id=#{post.id}"
    else
      render :json => post
    end
  end

  def assert_post_info(info)
    raise "wrong post info" if not info_has_all_values?(info, ["subject", "body", "source", "source_id"])
  end

  def assert_user_info(info)
    raise "wrong user info" if not info_has_all_values?(info, ["email"])
  end
end
