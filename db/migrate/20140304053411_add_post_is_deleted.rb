class AddPostIsDeleted < ActiveRecord::Migration
  def change
    add_column :posts, :is_deleted, :boolean, :null => false, :default => false
  end
end
