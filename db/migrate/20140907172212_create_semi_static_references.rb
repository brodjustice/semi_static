class CreateSemiStaticReferences < ActiveRecord::Migration
  def change
    create_table :semi_static_references do |t|
      t.string          :title
      t.text            :body
      t.text            :quote
      t.boolean         :show_in_side_bar, :default => false
      t.integer         :position, :default => 0
      t.string          :logo_file_name
      t.string          :logo_content_type
      t.integer         :logo_file_size
      t.string          :locale, :default => 'en'
      t.timestamps
    end
  end
end
