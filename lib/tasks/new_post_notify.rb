require 'tasks/task_helper'
require 'rails_autolink'

module Tasks
  class NewPostNotify
    @queue = :new_post
    
    def self.perform(post_id)
      post_id = post_id.to_i
      puts "new post notify: #{post_id}"
      post = Post.find_by_id(post_id)
      if not post
        puts "  no post: #{post_id}"
        return
      end
      puts "  subject: #{post.subject}"
      begin
        users = Tasks::TaskHelper::find_new_post_notified_users
        aliases = users.map{|user| user.email}
        puts "  sending mail to: #{aliases}"
        params = {"post" => post}
        puts params
        puts "  send mail: #{Tasks::TaskHelper::send_mail(aliases, "new_post", "[Woodenfish] #{post.subject}", params)}"
      rescue Exception => e
        puts e.message
        puts e.backtrace.inspect
      end
    end

    private

  end
end
