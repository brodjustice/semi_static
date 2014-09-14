class CreateSemiStaticLinks < ActiveRecord::Migration
  def change
    create_table :semi_static_links do |t|
      t.string :name
      t.string :url
      t.integer :position, :default => 0
      t.integer :fcol_id

      t.timestamps
    end
  end
end
