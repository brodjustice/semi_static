class CreateSemiStaticHreflangs < ActiveRecord::Migration
  def change
    create_table :semi_static_hreflangs do |t|
      t.string :locale
      t.string :href
      t.integer :seo_id
      t.timestamps
    end
  end
end
