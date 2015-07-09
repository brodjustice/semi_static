class CreateSemiStaticClickAds < ActiveRecord::Migration
  def change
    create_table :semi_static_click_ads do |t|
      t.integer	        :entry_id
      t.string		:url
      t.string		:client
      t.timestamps
    end
  end
end
