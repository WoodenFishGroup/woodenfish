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
        self.info "  can't find comment, wrong comment_id: #{comment_id}"
        return
      end
      self.info "  post: #{comment.post.subject}"
      self.info "  commentted by: #{comment.user.name}"
      self.info "  body: #{comment.body}"
      users = User.find_new_comment_notified_users
      other_commented_users = comment.post.comments.map {|c| c.user_id}
      comment_body_to_match = (comment.body + " ").downcase
      reply_all = comment_body_to_match.match(/@all[\W]+/)
      emails = []
      users.each do |u|
        reply = comment_body_to_match.match(/@(#{u.alias}|#{u.short_alias})[\W]+/)
        if u.id == comment.post.user_id || other_commented_users.include?(u.id) || reply_all || reply
          emails << u.email
        end
      end
      self.info "  send to: #{emails}"
      begin
        NotificationMailer.new_comment_notify(comment, emails).deliver
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
