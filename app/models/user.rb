require 'json'
require 'net/http'


class User < ActiveRecord::Base

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
  end

  def notify_policy
    @notify_policy ||= NotifyPolicy.new notification
    @notify_policy
  end

  def stared?(post)
    @stared_post_ids ||= stared_posts.select("posts.id").map(&:id)
    @stared_post_ids.include?(post.id)
  end

  def self.find_new_post_notified_users
    # TODO may need cache
    User.find(:all).select {|u| u.notify_policy.new_post_notify? }
  end

  def self.find_new_comment_notified_users
    # TODO may need cache
    User.find(:all).select {|u| u.notify_policy.new_comment_notify? }
  end

  def self.query_or_create_user(query)
    user = query_user(query)
    if not user
      name = query["name"] || get_name_from_email(query["email"])
      email = query["email"]
      User.create(:name => name, :email => email,
                  :avartar => query_hulu_employee_avartar(name, email),
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

  def self.query_hulu_employee_avartar(name, email)
    url = 'http://intranet.hulu.com/Contacts/GetContacts2.aspx?office=0'
    params = {:search => name, :dir => "ASC", :start => 0, :limit => 999, :sort => "name"}
    resp = Net::HTTP.post_form(URI.parse(url), params)
    json = JSON.parse(resp.body)
    #TODO find the most accurate one
    if json["contacts"].size > 0
      "http://intranet.hulu.com/#{json["contacts"][0]["photo_file_name"]}"
    else
      "http://www.gravatar.com/avatar/a"
    end
  end
end
