class SemiStaticTagHreflangTags < ActiveRecord::Migration[5.2]
  def change
    create_table :semi_static_tag_hreflang_tags, :id => false do |t|
      t.integer  :tag_id
      t.integer  :href_tag_id
    end
    add_column :semi_static_hreflangs, :href_equiv_entry_id, :integer
  end
end
