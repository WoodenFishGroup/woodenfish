require 'json'
require 'resque'
require 'tasks/new_post_notification'

class PostsController < ApplicationController

  def sample

  end

  # NOTE: for easier debugging
  def portal_submit
    user_info = {"email" => params[:user_email]}
    post_info = {
        "subject" => params[:post_subject],
        "body" => params[:post_body],
        "source" => "portal",
        "source_id" => Time.now.utc.to_i.to_s
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

