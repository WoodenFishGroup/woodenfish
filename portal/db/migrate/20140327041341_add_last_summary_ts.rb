class AddLastSummaryTs < ActiveRecord::Migration
  def change
    add_column :users, :last_summary_ts, :datetime
  end
end
