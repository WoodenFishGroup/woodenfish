class AddUserOtherEmails < ActiveRecord::Migration
  def change
    add_column :users, :other_emails, :string
    add_index :users, [:other_emails]
  end
end
