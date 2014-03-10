class CommentsController < ApplicationController

  COMMENTS_PER_PAGE = 100

  def create
    user_info = (params[:user] || {})
    comment_info = {
      "source" => "portal_comment",
      "source_id" => Time.now.utc.to_i.to_s
    }.merge(params[:comment] || {})
    create_comment(user_info, comment_info)
  end

  def index
    @comments = Comment
      .where(is_deleted: 0, post_id: params[:post_id].to_i)
      .order("id DESC")
      .paginate(page: params[:page], per_page: COMMENTS_PER_PAGE)
    @post_id = params[:post_id].to_i
  end

  private

  def create_comment(user_info, comment_info)
    assert_user_info(user_info)
    assert_comment_info(comment_info)
    user = User.query_or_create_user(user_info)
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
