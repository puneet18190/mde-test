class CreateLikes < ActiveRecord::Migration
  
  def change
    create_table :likes do |t|
      t.integer :lesson_id, :null => false, :on_delete => :cascade
      t.integer :user_id, :null => false
      t.timestamps
    end
  end
  
end
