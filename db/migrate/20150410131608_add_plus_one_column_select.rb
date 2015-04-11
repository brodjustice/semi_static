class AddPlusOneColumnSelect < ActiveRecord::Migration
  def up
    remove_column :semi_static_tags, :use_as_plus_one_column
    add_column :semi_static_tags, :side_bar_tag_id, :integer
    add_column :semi_static_entries, :side_bar_tag_id, :integer
  end

  def down
    remove_column :semi_static_tags, :side_bar_tag_id
    remove_column :semi_static_entries, :side_bar_tag_id
    add_column :semi_static_tags, :use_as_plus_one_column, :boolean, :deafult => :false
  end
end
