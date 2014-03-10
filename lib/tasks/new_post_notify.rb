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
        NotificationMailer.new_post_notify(post).deliver
      rescue Exception => e
        puts e.message
        puts e.backtrace.inspect
      end
    end
  end
end
