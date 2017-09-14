class CreateSlides < ActiveRecord::Migration
  
  def change
    create_table :slides do |t|
      t.integer :lesson_id,         null: false, on_delete: :cascade
      t.string  :title
      t.text    :text
      t.integer :position,          null: false, index: { unique: true, with: :lesson_id }
      t.column  :kind, :slide_type, null: false
      t.text    :metadata
      t.timestamps
    end
  end
  
end
