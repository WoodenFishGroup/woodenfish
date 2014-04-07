require 'nokogiri'

class NotificationMailer < ActionMailer::Base
  layout 'mail'
  add_template_helper(ApplicationHelper)

  def summary(user, new_posts, new_comments, top_starred_posts)
    logger.info "sending mail to #{user.email}"
    post_str = (new_posts.size > 0 ? "#{new_posts.size} new posts" : "")
    comment_str = (new_comments.size > 0 ? "#{new_comments.size} new comments" : "")
    subject = "[WoodenFish Daily] #{post_str} #{", " if post_str.size > 0} #{comment_str}"
    @user = user
    @new_posts = new_posts.sort {|x,y| x.user.id <=> y.user.id}
    @new_comments = new_comments.sort {|x,y| [x.post.id, x.created] <=> [y.post.id, y.created]}
    @top_starred_posts = top_starred_posts.sort {|x,y| [y.stars_count, y.created] <=> [x.stars_count, x.created]}
    @ranked_users = User.find(:all).sort {|x,y| [y.score, y.posts_count, y.comments_count, y.stars_count] <=> [x.score, x.posts_count, x.comments_count, x.stars_count]}
    mail(from: default_from, to: user.email, subject: subject)
  end

  def new_post_notify(post)
    users = User.find_new_post_notified_users
    aliases = users.map{|user| user.email}
    subject = "[WoodenFish Post] #{post.subject}"
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
    subject = "[WoodenFish Comment] #{comment.post.subject}"
    @comment = comment
    logger.info "sending mail to #{aliases.to_s}"
    mail(from: format_from(comment.user),
         bcc: aliases,
         subject: subject,
         message_id: format_source_id(comment.source_id))
  end

  private
  def default_from
    %Q{"WoodenFish" <#{Rails.configuration.notify_from_alias}>}
  end

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
