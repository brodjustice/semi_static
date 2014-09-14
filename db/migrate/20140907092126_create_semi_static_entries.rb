class CreateSemiStaticEntries < ActiveRecord::Migration
  def change
    create_table :semi_static_entries do |t|
      t.string :title
      t.text :body
      t.text :summary
      t.boolean :home_page
      t.boolean :news_item
      t.integer :tag_id
      t.integer :position, :default => 0
      t.integer :summary_length, :default => 150
      t.boolean :image_in_news, :boolean
      t.string :locale, :default => 'en'



      # CSS stuff
      t.string :style_class, :default => 'normal'
      t.string :background_colour, :default => 'white'
      t.string :colour, :default => '#181828'
      t.string :header_colour, :default => 'inherit'

      # Image for CMS
      t.string :img_file_name
      t.string :img_file_type
      t.integer :img_file_size

      # Attached document for CMS
      t.string :entries, :doc_file_name
      t.string :entries, :doc_file_type
      t.integer :entries, :doc_file_size
      t.text :entries, :doc_description

      t.timestamps
    end
  end
end
