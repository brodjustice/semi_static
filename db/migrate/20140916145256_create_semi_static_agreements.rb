class CreateSemiStaticAgreements < ActiveRecord::Migration
  def change
    create_table :semi_static_agreements do |t|
      t.text :body
      t.boolean :display, :default => true
      t.boolean :ticked_by_default, :default => false
      t.string :locale
      t.timestamps
    end

    create_table :semi_static_agreements_contacts, :id => false do |t|
      t.references :agreement, :contact
    end
  end
end
