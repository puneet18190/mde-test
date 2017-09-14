class CreateUsers < ActiveRecord::Migration
  
  def change
    create_table :users do |t|
      t.string  :email,              null: false, index: :unique
      t.string  :name,               null: false
      t.string  :surname,            null: false
      t.integer :school_level_id,    null: false
      t.string  :encrypted_password, null: false
      t.boolean :confirmed,          null: false, index: true
      t.boolean :active,             null: false, index: true
      t.integer :location_id         
      t.string  :confirmation_token,              index: true
      t.text    :metadata
      t.string  :password_token,                  index: true
      t.integer :purchase_id
      t.timestamps
    end
  end
  
end
