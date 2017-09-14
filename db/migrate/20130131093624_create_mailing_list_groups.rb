class CreateMailingListGroups < ActiveRecord::Migration
  def change
    create_table :mailing_list_groups do |t|
      t.references :user, :on_delete => :cascade
      t.string :name

      t.timestamps
    end
  end
end
