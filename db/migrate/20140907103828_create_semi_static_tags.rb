class CreateSemiStaticTags < ActiveRecord::Migration
  def change
    create_table :semi_static_tags do |t|
      t.string :name
      t.string :slug
      t.boolean :menu, :default => false
      t.integer :position, :default => 1
      t.string :predefined_class, :default => nil
      t.string :locale, :default => 'en'
      t.integer :max_entries_on_index_page, :default => 3
      t.string :sidebar_title

      # CSS
      t.string :colour, :default => 'inherit'

      # Icon as attachment
      t.string :icon_file_name
      t.string :icon_file_type
      t.integer :icon_file_size
      t.boolean :icon_in_menu, :default => true
      t.boolean :icon_resize, :default => false

      t.timestamps
    end
  end
end
