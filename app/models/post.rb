require 'resque'
require 'tasks/new_post_notification'

class Post < ActiveRecord::Base
  belongs_to :user
  has_many :comments, counter_cache: true

  after_create :enqueue_notification

  def starred_count
    if self.starred_by
      self.starred_by.split(',').select{|s| not s.empty?}.size
    else
      0
    end
  end

  def starred_by_user?(user_id)
    self.starred_by && (self.starred_by.include? ",#{user_id},")
  end

  def self.change_star_status(post, user_id)
    if post.starred_by_user?(user_id)
      post.starred_by[",#{user_id},"] = ","
    elsif
      if post.starred_by
        post.starred_by = ",#{(post.starred_by.split(',').select{|s| not s.empty?} + [user_id]).join(',')},"
      elsif
        post.starred_by = ",#{user_id},"
      end
    end
  end

  def self.query_by_source source, source_id
    self.where(source: source, source_id: source_id).first
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
    self.where(source: query["source"], source_id: query["source_id"]).first
  end

  private
  def enqueue_notification
    logger.info "enqueue new post"
    Resque.enqueue(Tasks::NewPostNotification, id)
  end
end
