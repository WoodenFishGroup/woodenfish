class CreateStars < ActiveRecord::Migration
  def up
    create_table :stars do |t|
      t.column :user_id, :integer, :null => false
      t.column :starable_type, :string, :null => false
      t.column :starable_id, :integer, :null => false
      t.timestamps
    end
    add_index :stars, :user_id
    add_index :stars, [:starable_type, :starable_id]
  end

  def down
    drop_table :stars
  end
end
