class AddUserNotification < ActiveRecord::Migration
  def change
    add_column :users, :notification, :text
  end
end
