class CreateBrowserCounts < ActiveRecord::Migration
  def change
    create_table :browser_counts do |t|
      t.integer :msg_id
      t.string :browser
      t.integer :count
      t.date :date

      t.timestamps
    end
  end
end
