module Tasks
  class NewPostNotification
    @queue = :new_posts

    def self.perform(post_id)
      post_id = post_id.to_i
      info "new post notify: #{post_id}"
      # wait to avoid mysql sync delay between master and slave
      sleep(1)
      post = Post.find_by_id(post_id)
      if not post
        info "  no post: #{post_id}"
        return
      end
      info "  subject: #{post.subject}"
      info "  user: #{post.user.name}"
      begin
        NotificationMailer.new_post_notify(post).deliver
      rescue Exception => e
        error(e)
      end
    end

    def info(message)
      puts message
      Rails.logger.info message
    end

    def error(e)
      puts e.message
      Rails.logger.error e.message
      puts e.backtrace.inspect
      Rails.logger.error e.backtrace.inspect
    end
  end
end
