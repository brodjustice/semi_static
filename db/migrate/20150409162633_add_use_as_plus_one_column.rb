class AddUseAsPlusOneColumn < ActiveRecord::Migration
  def change
    add_column :semi_static_tags, :use_as_plus_one_column, :boolean, :deafult => :false
  end
end
