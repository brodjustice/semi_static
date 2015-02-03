class AddNoFollowToSeo < ActiveRecord::Migration
  def change
    add_column :semi_static_seos, :no_index, :boolean, :default => false
  end
end
