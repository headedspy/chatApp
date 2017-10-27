class CreateDatabases < ActiveRecord::Migration[5.1]
  def change
    create_table :databases do |t|
      t.string :number
      t.string :data

      t.timestamps
    end
  end
end
