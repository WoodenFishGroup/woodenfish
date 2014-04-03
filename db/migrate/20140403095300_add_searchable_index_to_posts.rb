class AddSearchableIndexToPosts < ActiveRecord::Migration
  def up
    Post.connection.execute <<-SQL
      ALTER TABLE `posts`
        MODIFY COLUMN `source` VARCHAR(32) DEFAULT NULL,
        ADD FULLTEXT KEY `searchable`(`body`, `subject`),
        ENGINE=MyISAM;
    SQL
  end

  def down
    Post.connection.execute  <<-SQL
      ALTER TABLE `posts`
        MODIFY COLUMN `source` VARCHAR(255) DEFAULT NULL,
        DROP KEY `searchable`,
        ENGINE=InnoDB;
    SQL
  end
end
