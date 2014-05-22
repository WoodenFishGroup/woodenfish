class AddPostStarredBy < ActiveRecord::Migration
  def change
    add_column :posts, :starred_by, :string
  end
end
