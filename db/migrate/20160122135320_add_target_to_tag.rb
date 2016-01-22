class AddTargetToTag < ActiveRecord::Migration
  def change
    add_column :semi_static_tags, :target_tag_id, :integer
    add_column :semi_static_tags, :target_name, :string
  end
end
