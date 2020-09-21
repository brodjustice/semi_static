class SemiStaticTagHreflangTags < ActiveRecord::Migration[5.2]
  def change
    create_table :semi_static_tag_hreflang_tags, :id => false do |t|
      t.integer  :setting_tag_id
      t.integer  :href_tag_id
    end
  end
end
