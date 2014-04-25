class AddSearchableIndexToPosts < ActiveRecord::Migration
  def up
    ActiveRecord::Base.connection.execute <<-SQL
      ALTER TABLE `posts`
        MODIFY COLUMN `source` VARCHAR(32) DEFAULT NULL,
        ADD FULLTEXT KEY `searchable`(`body`, `subject`),
        ENGINE=MyISAM;
    SQL
  end

  def down
    ActiveRecord::Base.connection.execute <<-SQL
      ALTER TABLE `posts`
        MODIFY COLUMN `source` VARCHAR(255) DEFAULT NULL,
        DROP KEY `searchable`,
        ENGINE=InnoDB;
    SQL
  end
end
