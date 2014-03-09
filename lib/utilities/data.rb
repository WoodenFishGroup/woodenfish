require 'json'
require 'resque'
require 'tasks/new_post_notify'

module Utilities
  module Data

    def change_post_star_status(post, user_id)
      if post_starred_by_user?(post, user_id)
        post.starred_by[",#{user_id},"] = ","
      elsif
        if post.starred_by
          post.starred_by = ",#{(post.starred_by.split(',').select{|s| not s.empty?} + [user_id]).join(',')},"
        elsif
          post.starred_by = ",#{user_id},"
        end
      end
    end

    def starred_count(post)
      if post.starred_by
        post.starred_by.split(',').select{|s| not s.empty?}.size
      else
        0
      end
    end

    def post_starred_by_user?(post, user_id)
      post.starred_by && (post.starred_by.include? ",#{user_id},")
    end

    def query_or_create_user(query)
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

    def query_user(query)
      email = query["email"]
      User.where("email='#{email}' or other_emails like '%,#{email},%'").first
    end

    def get_name_from_email(email_address)
      name = email_address[0..(email_address.index("@") - 1)]
      name.sub('.', ' ').split.map(&:capitalize).join(' ')
    end

    def query_or_create_post(query, user)
      post = query_post(query)
      if not post
        Post.create(
            :subject => query["subject"],
            :body => query["body"],
            :user_id => user.id,
            :created => (if query["created"] then Time.at(query["created"]) else Time.now.utc end),
            :tags => query["tags"],
            :source => query["source"],
            :source_id => query["source_id"])
        post = query_post(query)
        Resque.enqueue(Tasks::NewPostNotify, post.id)
      end
      post
    end

    def query_post(query)
      Post.where(source: query["source"], source_id: query["source_id"]).first
    end

    private
    def query_hulu_employee_avartar(name, email)
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
end
