class RemoveUserCreate < ActiveRecord::Migration
  def change
    remove_column :users, :created
  end
end
