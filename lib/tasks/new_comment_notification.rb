module Tasks
  class NewCommentNotification
    @queue = :new_comments
    
    def self.perform(comment_id)
      comment_id = comment_id.to_i
      Rails.logger.info "new comment notify: #{comment_id}"
      comment = Comment.find(comment_id)
      if not comment
        Rails.logger.info "  no comment: #{comment_id}"
        return
      end
      Rails.logger.info "  subject: #{comment.post.subject}"
      begin
        NotificationMailer.new_comment_notify(comment).deliver
      rescue Exception => e
        Rails.logger.error e.message
        Rails.logger.error e.backtrace.inspect
      end
    end
  end
end
