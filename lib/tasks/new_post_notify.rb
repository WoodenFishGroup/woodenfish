class NewPostNotify
  @queue = :woodenfish_notify
  
  def self.perform(post_id)  
    # TODO
    puts "new post notify: #{post_id}"
  end  
end  
