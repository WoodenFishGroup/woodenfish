class NotificationMailer < ActionMailer::Base

  def new_post_notify(post)
    users = User.find_new_post_notified_users
    aliases = users.map{|user| user.email}
    subject = "[Woodenfish] #{post.subject}"
    @post = post
    logger.info "sending mail to #{aliases.to_s}"
    mail(from: format_from(post.user),
         bcc: aliases,
         subject: subject,
         message_id: format_source_id(post.source_id))
  end

  def new_comment_notify(comment)
    users = User.find_new_comment_notified_users
    aliases = users.map{|user| user.email}
    subject = "[Woodenfish] Comment: #{comment.post.subject}"
    @comment = comment
    logger.info "sending mail to #{aliases.to_s}"
    mail(from: format_from(comment.user),
         bcc: aliases,
         subject: subject,
         message_id: format_source_id(comment.source_id))
  end

  private
  def format_from(user)
    %Q{"#{user.name} (WoodenFish)" <#{Rails.configuration.notify_from_alias}>}
  end

  def format_source_id(source_id)
    if source_id =~ /^\<.*\>$/
      source_id
    else
      "<#{source_id}>"
    end
  end
end
