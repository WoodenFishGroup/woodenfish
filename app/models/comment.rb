require 'resque'
require 'tasks/new_comment_notification'

class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :commentable, polymorphic: true
  belongs_to :post, :counter_cache => true
  has_many :comments, as: :commentable, counter_cache: true

  after_create :enqueue_notification

  def self.get_or_create query, user
    comment = self.where(source: query["source"], source_id: query["source_id"]).first
    if comment.nil?
      if !query["post_id"].blank?
        commentable = Post.find(query["post_id"])
        post = commentable
      else
        commentable = Post.where(source: query["source"], source_id: query["commentable_source_id"]).first
        post = commentable
        if commentable.nil?
          commentable = Comment.where(source: query["source"], source_id: query["commentable_source_id"]).first
          post = commentable.post if commentable
        end
      end

      if !commentable.nil? && !post.nil?
        comment = Comment.create(
          :body => query["body"],
          :original_body => query["original_body"].blank? ? query["body"] : query["original_body"],
          :user_id => user.id,
          :created => (if query["created"] then Time.at(query["created"]) else Time.now.utc end),
          :commentable => commentable,
          :post => post,
          :source => query["source"],
          :source_id => query["source_id"])
      end
    end
    comment 
  end

  private
  def enqueue_notification
    logger.info "enqueue new comment"
    Resque.enqueue(Tasks::NewCommentNotification, id)
  end
end
