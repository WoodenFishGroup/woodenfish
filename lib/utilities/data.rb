module Utilities
  module Data
    def query_or_create_user(query)
      user = query_user(query)
      if not user
        name = query["name"] || get_name_from_email(query["email"])
        User.create(:name => name, :email => query["email"], :created => Time.now.utc)
        user = query_user(query)
      end
      user
    end

    def query_user(query)
      email = query["email"]
      User.where(email: email).or("other_emails like ?", "%,#{email},%").first
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
      end
      post
    end

    def query_post(query)
      Post.where(source: query["source"], source_id: query["source_id"]).first
    end
  end
end
