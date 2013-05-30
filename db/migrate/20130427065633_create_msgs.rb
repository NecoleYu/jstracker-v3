class CreateMsgs < ActiveRecord::Migration
  def change
    create_table :msgs do |t|
      t.integer :host_id
      t.integer :type_id
      t.string :msg
      t.integer :count

      t.timestamps
    end
  end
end
