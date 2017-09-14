class CreateBookmarks < ActiveRecord::Migration
  
  def change
    create_table :bookmarks do |t|
      t.integer :user_id, null: false
      t.integer :bookmarkable_id, null: false, references: nil
      t.column :bookmarkable_type, :teaching_object, null: false, index: { unique: true, with: [:bookmarkable_id, :user_id], name: 'index_bookmarks_on_bookmarkable_type_bookmarkable_id_user_id' }
      t.timestamps
    end
  end
  
end
