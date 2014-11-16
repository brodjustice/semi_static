class AddYoutubeToEntries < ActiveRecord::Migration
  def change
    add_column :semi_static_entries, :youtube_id_str, :string
  end
end
