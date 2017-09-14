class CreateMediaElements < ActiveRecord::Migration
  
  def change
    create_table :media_elements do |t|
      t.integer  :user_id,         :null => false
      t.string   :sti_type,        :null => false
      t.string   :media
      t.string   :title,           :null => false
      t.text     :description,     :null => false
      t.text     :metadata
      t.boolean  :converted,       :null => false, :default => false
      t.boolean  :is_public,       :null => false, :default => false
      t.datetime :publication_date
      t.timestamps
    end
  end
  
end
