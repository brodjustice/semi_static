class AddHeaderHtmlToEntry < ActiveRecord::Migration[5.2]
  def change
    add_column :semi_static_entries, :header_html, :text
  end
end
