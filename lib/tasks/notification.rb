module Tasks
  class Notification
    @queue = :notifications
    
    def self.perform(param)
      case param["notifyable_type"].to_sym
      when :new_post
        return new_post_notification(param["notifyable_id"])
      when :new_comment
        return new_comment_notification(param["notifyable_id"])
      else
        return
      end
    end

    def self.new_post_notification(post_id)
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

    def self.new_comment_notification(comment_id)
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
