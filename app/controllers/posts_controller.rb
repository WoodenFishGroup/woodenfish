require 'json'
require 'utilities/data'

class PostsController < ApplicationController
  include Utilities::Data

  def sample
  end

  # NOTE: this is for submit testing data from portal page
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

  # params should look like:
  # {
  # :user => {
  #   :name => ...,
  #   :email => ...
  # }, 
  # :post => {
  #   :subject => ...,
  #   :body => ...,
  #   :source => ...,
  #   :source_id => ...
  # }
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
    user = query_or_create_user(user_info)
    post = query_or_create_post(post_info, user)
    render :json => post
  end

  def assert_post_info(info)
    raise "wrong post info" if not info_has_all_values?(info, ["subject", "body", "source", "source_id"])
  end

  def assert_user_info(info)
    raise "wrong user info" if not info_has_all_values?(info, ["email"])
  end

end

