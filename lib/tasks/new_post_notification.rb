module Tasks
  class NewPostNotification
    @queue = :new_posts
    
    def self.perform(post_id)
      post_id = post_id.to_i
      Rails.logger.info "new post notify: #{post_id}"
      post = Post.find_by_id(post_id)
      if not post
        Rails.logger.info "  no post: #{post_id}"
        return
      end
      Rails.logger.info "  subject: #{post.subject}"
      begin
        NotificationMailer.new_post_notify(post).deliver
      rescue Exception => e
        Rails.logger.error e.message
        Rails.logger.error e.backtrace.inspect
      end
    end
  end
end
