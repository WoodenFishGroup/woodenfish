class AddIsDeletedToComments < ActiveRecord::Migration
  def change
    add_column :comments, :is_deleted, :boolean, :default => false, :null => false
  end
end
