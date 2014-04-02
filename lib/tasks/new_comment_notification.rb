module Tasks
  class NewCommentNotification
    @queue = :new_comments

    def self.perform(comment_id)
      comment_id = comment_id.to_i
      info "new comment notify: #{comment_id}"
      # wait to avoid mysql sync delay between master and slave
      sleep(1)
      comment = Comment.find(comment_id)
      if not comment
        info "  no comment: #{comment_id}"
        return
      end
      info "  post: #{comment.post.subject}"
      info "  commentted by: #{comment.user.name}"
      info "  body: #{comment.body}"
      begin
        NotificationMailer.new_comment_notify(comment).deliver
      rescue Exception => e
        error(e)
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
