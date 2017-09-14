class CreateVirtualClassroomLessons < ActiveRecord::Migration
  
  def change
    create_table :virtual_classroom_lessons do |t|
      t.integer :lesson_id, :null => false, :on_delete => :cascade
      t.integer :user_id, :null => false
      t.integer :position
      t.timestamps
    end
  end
  
end
