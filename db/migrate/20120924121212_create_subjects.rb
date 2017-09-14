class CreateSubjects < ActiveRecord::Migration
  
  def change
    create_table :subjects do |t|
      t.string :description, :null => false
      t.timestamps
    end
  end
  
end
