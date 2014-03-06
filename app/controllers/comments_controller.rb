require 'utilities/data'

class CommentsController < ApplicationController
  include Utilities::Data

  def create
    user_info = (params[:user] || {})
    comment_info = {
      "source" => "portal_comment",
      "source_id" => Time.now.utc.to_i.to_s
    }.merge(params[:comment] || {})
    create_comment(user_info, comment_info)
  end

  private

  def create_comment(user_info, comment_info)
    assert_user_info(user_info)
    assert_comment_info(comment_info)
    user = query_or_create_user(user_info)
    comment = Comment.get_or_create(comment_info, user)
    render :json => comment.to_json
  end

  def assert_comment_info(info)
    raise "wrong comment info" if not info_has_all_values?(info, ["body", "source", "source_id"])
  end

  def assert_user_info(info)
    raise "wrong user info" if not info_has_all_values?(info, ["email"])
  end

end
