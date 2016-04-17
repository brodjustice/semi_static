class AddBannerToNewsletters < ActiveRecord::Migration
  def change
    add_column :semi_static_newsletters, :banner_id, :integer
  end
end
