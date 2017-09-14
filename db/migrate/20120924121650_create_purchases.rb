class CreatePurchases < ActiveRecord::Migration
  
  def change
    create_table :purchases do |t|
      t.string   :name,             null: false
      t.string   :responsible,      null: false
      t.string   :phone_number      
      t.string   :fax               
      t.string   :email,            null: false
      t.string   :ssn_code          
      t.string   :vat_code          
      t.string   :address           
      t.string   :postal_code       
      t.string   :city              
      t.string   :country           
      t.integer  :location_id       
      t.integer  :accounts_number,  null: false
      t.boolean  :includes_invoice, null: false
      t.datetime :release_date,     null: false
      t.datetime :start_date,       null: false
      t.datetime :expiration_date,  null: false
      t.string   :token,            null: false
      t.timestamps
    end
  end
  
end
