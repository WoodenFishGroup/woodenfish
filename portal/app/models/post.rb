require 'resque'
require 'tasks/new_post_notification'

class Post < ActiveRecord::Base
  belongs_to :user
  has_many :comments, -> {where("is_deleted = 0")}
  has_many :stars, :as => :starable

  after_create :enqueue_notification

  attr_accessor :stared_by_current_user

  def starred_by_user?(user_id)
    !stars.where(:user_id => user_id).empty?
  end

  def change_star_status(user_id, toggle = true)
    star = stars.where(:user_id => user_id).first
    if star
      star.destroy if toggle
    else
      stars.new(:user_id => user_id).save
    end
  end

  def self.query_or_create_post(query, user)
    post = query_post(query)
    create = false
    if not post
      Post.create(
          :subject => query["subject"].to_s.strip,
          :body => query["body"].to_s.strip,
          :user_id => user.id,
          :created => (if query["created"] then Time.at(query["created"]) else Time.now.utc end),
          :tags => query["tags"].to_s.strip,
          :source => query["source"],
          :source_id => query["source_id"])
      post = query_post(query)
      create = true
    end
    [post, create]
  end

  def self.query_post(query)
    self.where(source_id: query["source_id"]).first
  end

  private
  def enqueue_notification
    logger.info "enqueue new post"
    Resque.enqueue(Tasks::NewPostNotification, id)
  end
end
