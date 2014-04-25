class AddOriginalBodyToComments < ActiveRecord::Migration
  def change
    add_column :comments, :original_body, :text, :null => false
  end
end
