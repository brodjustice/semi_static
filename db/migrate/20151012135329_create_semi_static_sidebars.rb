class CreateSemiStaticSidebars < ActiveRecord::Migration
  def change
    create_table :semi_static_sidebars do |t|
      t.string		:title
      t.text		:body
      t.string		:style_class
      t.string		:color, :default => 'inherit'
      t.string		:bg_color, :default => 'inherit'
      t.string		:bg_file_name
      t.string		:bg_content_type
      t.integer		:bg_file_size
      t.timestamps
    end
    add_column :semi_static_entries, :sidebar_id, :integer
  end
end
