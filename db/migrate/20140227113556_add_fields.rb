class AddFields < ActiveRecord::Migration
  def change
    add_column :posts, :source, :string 
    add_column :posts, :source_id, :string 
    add_index :posts, [:source, :source_id], :unique => true
    add_index :users, [:email], :unique => true
  end
end
