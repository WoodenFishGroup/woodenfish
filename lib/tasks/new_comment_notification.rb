module Tasks
  class NewCommentNotification
    @queue = :new_comments

    def self.perform(comment_id)
      comment_id = comment_id.to_i
      self.info "new comment notify: #{comment_id}"
      # wait to avoid mysql sync delay between master and slave
      sleep(1)
      comment = Comment.find(comment_id)
      if not comment
        self.info "  no comment: #{comment_id}"
        return
      end
      self.info "  post: #{comment.post.subject}"
      self.info "  commentted by: #{comment.user.name}"
      self.info "  body: #{comment.body}"
      begin
        NotificationMailer.new_comment_notify(comment).deliver
      rescue Exception => e
        self.error(e)
      end
    end

    def self.info(message)
      puts message
      Rails.logger.info message
    end

    def self.error(e)
      puts e.message
      Rails.logger.error e.message
      puts e.backtrace.inspect.to_s
      Rails.logger.error e.backtrace.inspect
    end
  end
end
