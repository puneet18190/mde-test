class CreateMailingListAddresses < ActiveRecord::Migration
  def change
    create_table :mailing_list_addresses do |t|
      t.integer :group_id, foreign_key: { references: :mailing_list_groups }, :on_delete => :cascade
      t.string :heading
      t.string :email

      t.timestamps
    end
  end
end
