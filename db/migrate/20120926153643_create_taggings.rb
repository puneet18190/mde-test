class CreateTaggings < ActiveRecord::Migration
  
  def change
    create_table :taggings do |t|
      t.integer :tag_id, :null => false
      t.integer :taggable_id, :references => nil, :null => false
      t.column :taggable_type, :teaching_object, :null => false, :index => {:with => [:taggable_id, :tag_id], :unique => true}
      t.timestamps
    end
  end
  
end
