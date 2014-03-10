class NotificationMailer < ActionMailer::Base
  default from: Rails.configuration.notify_from_alias

  def new_post_notify(post)
    users = User.find_new_post_notified_users
    aliases = users.map{|user| user.email}
    puts "sending mail to: #{aliases}"
    subject = "[Woodenfish] #{post.subject}"
    @post = post
    mail(bcc: aliases, subject: subject, message_id: post.source_id)
    puts "sended mail"
  end
end
