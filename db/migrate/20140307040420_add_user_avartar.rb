class AddUserAvartar < ActiveRecord::Migration
  def change
    add_column :users, :avartar, :string, :null => false, :default => "http://www.gravatar.com/avatar/a"
  end
end
