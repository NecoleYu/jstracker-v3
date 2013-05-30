class CreateDailyCounts < ActiveRecord::Migration
  def change
    create_table :daily_counts do |t|
      t.integer :msg_id
      t.string :hourlycount
      t.integer :count
      t.date :date

      t.timestamps
    end
  end
end
