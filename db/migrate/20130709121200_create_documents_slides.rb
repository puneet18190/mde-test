class CreateDocumentsSlides < ActiveRecord::Migration
  
  def change
    create_table :documents_slides do |t|
      t.integer :document_id,      :null => false, :on_delete => :cascade
      t.integer :slide_id,         :null => false, :on_delete => :cascade
      t.timestamps
    end
  end
  
end
