require 'json'
require 'digest'
require 'net/http'
require 'active_support/all'

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :stars
  has_many :stared_posts, :through => :stars, :source => :starable, :source_type => "Post"
  has_many :posts

  class NotifyPolicy
    def initialize(notification_string)
      @json = JSON.parse(notification_string || "{}")
    end

    def new_post_notify?
      @json.fetch('new_post', true)
    end

    def new_comment_notify?
      @json.fetch('new_comment', true)
    end

    def summary_notify?
      summary = @json.fetch('summary', {})
      summary.fetch('enabled', true)
    end

    def summary_send_time_in_day
      summary = @json.fetch('summary', {})
      # NOTE: UTC seconds in day
      # the default is 18:00 CST
      summary.fetch('time_in_day', 36000)
    end
  end

  def alias
    name.sub(" ", "").downcase
  end

  def short_alias
    name.split(" ")[0].downcase
  end

  def has_alias?(ali)
    ali == self.alias || ali == short_alias
  end

  def notify_policy
    @notify_policy ||= NotifyPolicy.new notification
    @notify_policy
  end

  def send_summary_now?
    return false if not notify_policy.summary_notify?
    now = Time.now.utc.to_i
    now_seconds_in_day = now % (24 * 3600)
    last_summary_time = last_summary_ts.nil? ? now - 3.days : last_summary_ts.to_i
    (last_summary_time + 12.hours < now) && (notify_policy.summary_send_time_in_day < now_seconds_in_day) && (now_seconds_in_day < notify_policy.summary_send_time_in_day + 30.minutes)
  end

  def stared?(post)
    @stared_post_ids ||= stared_posts.select("posts.id").map(&:id)
    @stared_post_ids.include?(post.id)
  end

  def score
    s = 0
    posts = Post.where(:user_id => id, :is_deleted => false).order("id desc")
    comments = Comment.where(:user_id => id, :is_deleted => false).order("id desc")
    stars = Star.where(:user_id => id).order("id desc")
    posts.each do |p|
      s += [0, 20 + p.comments_count + p.stars_count - days_to_now(p.created)].max
    end
    sub_weight = 0
    comments.each do |c|
      s += [0, 8 - sub_weight - days_to_now(c.created)].max
      sub_weight += 1
    end
    sub_weight = 0
    stars.each do |st|
      s += [0, 5 - sub_weight - days_to_now(st.created_at)].max
      sub_weight += 0.5
    end
    # for new users
    s += [0, 20 - days_to_now(created) * 2].max
    s.to_int
  end

  # TODO assign created time
  def created
    remember_created_at || Time.now.utc
  end

  def posts_count
    Post.where(:user_id => id, :is_deleted => false).size
  end

  def comments_count
    Comment.where(:user_id => id, :is_deleted => false).size
  end

  def stars_count
    Star.where(:user_id => id).size
  end

  def self.find_new_post_notified_users
    User.find(:all).select {|u| u.notify_policy.new_post_notify? }
  end

  def self.find_new_comment_notified_users
    User.find(:all).select {|u| u.notify_policy.new_comment_notify? }
  end

  def self.query_or_create_user(query)
    user = query_user(query)
    if not user
      name = query["name"] || get_name_from_email(query["email"])
      email = query["email"]
      User.create(:name => name, :email => email,
                  :avartar => default_gravatar(email),
                  :created => Time.now.utc)
      user = query_user(query)
    end
    user
  end

  def self.query_user(query)
    if query.include?("id")
      User.find(query["id"])
    else
      email = query["email"]
      User.where("email='#{email}' or other_emails like '%,#{email},%'").first
    end
  end

  def self.get_name_from_email(email_address)
    name = email_address[0..(email_address.index("@") - 1)]
    name.sub('.', ' ').split.map(&:capitalize).join(' ')
  end

  private

  def days_to_now(time)
    ((Time.now.utc - time) / (3600 * 24)).to_int
  end

  def self.default_gravatar(email)
    "http://www.gravatar.com/avatar/#{Digest::MD5.hexdigest(email)}"
  end
end
