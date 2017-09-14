class CreateUsersSubjects < ActiveRecord::Migration
  
  def change
    create_table :users_subjects do |t|
      t.integer :user_id, :null => false
      t.integer :subject_id, :null => false
      t.timestamps
    end
  end
  
end
