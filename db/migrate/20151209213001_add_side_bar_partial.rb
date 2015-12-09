class AddSideBarPartial < ActiveRecord::Migration
  def up
    add_column :semi_static_sidebars, :partial, :string, :default => ''
  end

  def down
    remove_column :semi_static_sidebars, :partial
  end
end
