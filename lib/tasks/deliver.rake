require 'active_support/all'

namespace :deliver do
  task run: :environment do
    info "deliver is running..."
    run_resque_thread
    while true
      info "----------------"
      check_to_send_summary
      info "wait for a while..."
      sleep(10 * 60)
    end
  end

  def check_to_send_summary
    info "check to send summary"
    users = User.find(:all).select {|u| u.send_summary_now? }
    info "no user need summary at this time" if users.size == 0
    now = Time.now.utc
    users.each do |user|
      check_time = user.last_summary_ts || (now - 1.days - 2.hours)
      long_before = check_time - 14.days
      new_posts = Post.where(:created => check_time..now)
      new_comments = Comment.where(:created => check_time..now)
      top_posts = Post.where(\
          ["created>? and created<? and stars_count>0", long_before, check_time])\
          .order('stars_count desc').limit(10)
      info "  sending to #{user.name}, #{user.email}"
      info "    new posts: #{new_posts.map {|p| p.subject}}"
      info "    new comments: #{new_comments.map {|c| "user:" + c.user_id.to_s + " on post " + c.post_id.to_s}}"
      info "    top posts: #{top_posts.map {|p| p.subject}}"
      NotificationMailer.summary(user, new_posts, new_comments, top_posts).deliver
      info "    mark last_summary_ts to #{now}"
      user.update(:last_summary_ts => now)
    end
  end

  def run_resque_thread
    command = "RAILS_ENV=#{Rails.env.to_s} QUEUE=* rake resque:work"
    Thread.new { system(command) }
  end

  def info(message)
    puts message
    Rails.logger.info message
  end
end
