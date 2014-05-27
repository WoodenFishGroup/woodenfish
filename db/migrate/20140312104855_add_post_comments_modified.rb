class AddPostCommentsModified < ActiveRecord::Migration
  def change
    add_column :posts, :modified, :datetime
    add_column :posts, :modified_by, :integer
    add_column :comments, :modified, :datetime
    add_column :comments, :modified_by, :integer

    add_index :posts, :modified_by
    add_index :comments, :modified_by
  end
end
