class CreateSemiStaticContacts < ActiveRecord::Migration
  def change
    create_table :semi_static_contacts do |t|
      t.string          :name
      t.string          :surname
      t.string          :email
      t.string          :telephone
      t.text            :message
      t.timestamps
    end
  end
end
