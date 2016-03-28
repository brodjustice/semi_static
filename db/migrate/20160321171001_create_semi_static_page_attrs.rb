class CreateSemiStaticPageAttrs < ActiveRecord::Migration
  def change
    create_table :semi_static_page_attrs do |t|
      t.string	:attr_key
      t.string  :attr_value  
      t.string  :page_attrable_type
      t.integer :page_attrable_id
    end
  end
end
