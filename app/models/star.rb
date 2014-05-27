class Star < ActiveRecord::Base
  belongs_to :user
  belongs_to :starable, :polymorphic => true, :counter_cache => :stars_count
end
