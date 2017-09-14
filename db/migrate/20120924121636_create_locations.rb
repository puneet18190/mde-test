class CreateLocations < ActiveRecord::Migration
  
  def change
    create_table :locations do |t|
      t.string :name, null: false
      t.string :sti_type
      t.string :ancestry, index: true
      t.string :code
      t.timestamps
    end
  end
  
end
