require 'json'
require 'utilities/data'

class CollectorController < ApplicationController
  include Utilities::Data

  def sample
  end

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

  def feed
    user_request = params[:user]
    post_request = params[:post]
    user_info = JSON.parse(user_request)
    post_info = JSON.parse(post_request)
    feed_impl(user_info, post_info)
  end

  private

  def feed_impl(user_info, post_info)
    @user_info = user_info
    @post_info = post_info
    begin
      assert_user_info(user_info)
      assert_post_info(post_info)
      @user = query_or_create_user(user_info)
      @post = query_or_create_post(post_info, @user)
    rescue => e
      @error_message = e.to_s
      @error_trace = e.backtrace
    end
    render :template => "collector/feed_result"
  end

  def assert_post_info(info)
    raise "wrong post info" if not info_has_all_values?(info, ["subject", "body", "source", "source_id"])
  end

  def assert_user_info(info)
    raise "wrong user info" if not info_has_all_values?(info, ["email"])
  end

  def info_has_all_values?(info, keys)
    keys.each do |key|
      return false if info[key].nil? || info[key].empty?
    end
    true
  end
end

