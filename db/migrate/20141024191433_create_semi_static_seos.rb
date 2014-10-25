class CreateSemiStaticSeos < ActiveRecord::Migration
  def change
    create_table :semi_static_seos do |t|
      t.string	:keywords
      t.string  :title
      t.string  :description
      t.boolean :master, :default => false
      t.string  :locale
      t.string  :seoable_type
      t.integer :seoable_id
      t.timestamps
    end
  end
end
