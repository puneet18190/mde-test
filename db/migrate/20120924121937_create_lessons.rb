class CreateLessons < ActiveRecord::Migration
  
  def change
    create_table :lessons do |t|
      t.column  :uuid, :uuid,         null: false, default: { expr: 'uuid_generate_v4()' }
      t.integer :user_id,             null: false
      t.integer :school_level_id,     null: false
      t.integer :subject_id,          null: false
      t.string  :title,               null: false
      t.text    :description,         null: false
      t.boolean :is_public,           null: false, default: false
      t.integer :parent_id,                                                                 on_delete: :set_null
      t.boolean :copied_not_modified, null: false
      t.string  :token,               null: false
      t.text    :metadata
      t.boolean :notified,            null: false, default: true
      t.timestamps
    end
  end
  
end
