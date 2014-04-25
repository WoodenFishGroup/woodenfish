class CreateComments < ActiveRecord::Migration
  def up
    create_table :comments do |t|
      t.column :commentable_type, :string, :null => false
      t.column :commentable_id, :integer, :null => false
      t.column :comments_count, :integer, :default => 0, :null => false #in case we allow comment to be commentable too
      t.column :source, :string, :null => false
      t.column :source_id, :string, :null => false
      t.column :user_id, :integer, :null => false
      t.column :body, :text
      t.column :created, :datetime, :null => false
    end
    add_index :comments, [:commentable_type, :commentable_id]
    add_index :comments, :user_id

    add_column :posts, :comments_count, :integer, :default => 0, :null => false
  end

  def down
    remove_column :posts, :comments_count

    drop_table :comments
  end
end
