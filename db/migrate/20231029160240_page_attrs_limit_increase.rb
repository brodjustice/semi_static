class PageAttrsLimitIncrease < ActiveRecord::Migration[5.2]
  def change
    change_column :semi_static_page_attrs, :attr_value, :string, limit: 511
  end
end
