class NotificationMailer < ActionMailer::Base
  default from: Rails.configuration.notify_from_alias

  def new_post_notify(post)
    users = User.find_new_post_notified_users
    aliases = users.map{|user| user.email}
    subject = "[Woodenfish] #{post.subject}"
    @post = post
    mail(bcc: aliases, subject: subject, message_id: post.source_id)
  end

  def new_comment_notify(comment)
    users = User.find_new_comment_notified_users
    aliases = users.map{|user| user.email}
    subject = "Re: [Woodenfish] #{comment.post.subject}"
    @comment = comment
    mail(bcc: aliases, subject: subject, message_id: comment.source_id)
  end
end
