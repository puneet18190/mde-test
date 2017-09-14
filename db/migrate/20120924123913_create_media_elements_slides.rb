class CreateMediaElementsSlides < ActiveRecord::Migration
  
  def change
    create_table :media_elements_slides do |t|
      t.integer  :media_element_id, :null => false, :on_delete => :cascade
      t.integer  :slide_id,         :null => false, :on_delete => :cascade
      t.integer  :position,         :null => false
      t.text     :caption
      t.boolean  :inscribed,        :null => false, :default => false
      t.integer  :alignment
      t.timestamps
    end
  end
  
end
