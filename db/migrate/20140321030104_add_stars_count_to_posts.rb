class AddStarsCountToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :stars_count, :integer, :default => 0, :null => false
  end
end
