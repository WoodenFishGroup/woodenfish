class InitialMigration < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.column :name, :string, :null => false
      t.column :email, :string, :null => false
      t.column :created, :datetime, :null => false
    end
    create_table :posts do |t|
      t.column :subject, :string, :null => false
      t.column :body, :text
      t.integer :user_id, :null => false
      t.column :created, :datetime, :null => false
      t.column :tags, :string
    end
    add_index :posts, [:user_id]
  end
end
