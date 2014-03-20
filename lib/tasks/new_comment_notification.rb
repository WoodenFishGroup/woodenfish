module Tasks
  class NewCommentNotification
    @queue = :new_comments
    
    def self.perform(comment_id)
      comment_id = comment_id.to_i
      Rails.logger.info "new comment notify: #{comment_id}"
      # wait to avoid mysql sync delay between master and slave
      sleep(1)
      comment = Comment.find(comment_id)
      if not comment
        Rails.logger.info "  no comment: #{comment_id}"
        return
      end
      Rails.logger.info "  post: #{comment.post.subject}"
      Rails.logger.info "  commentted by: #{comment.user.name}"
      Rails.logger.info "  body: #{comment.body}"
      begin
        NotificationMailer.new_comment_notify(comment).deliver
      rescue Exception => e
        Rails.logger.error e.message
        Rails.logger.error e.backtrace.inspect
      end
    end
  end
end
