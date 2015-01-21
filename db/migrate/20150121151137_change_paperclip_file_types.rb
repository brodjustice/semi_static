class ChangePaperclipFileTypes < ActiveRecord::Migration
  def up
    rename_column :semi_static_entries, :doc_file_type, :doc_content_type
    rename_column :semi_static_entries, :img_file_type, :img_content_type
  end

  def down
    rename_column :semi_static_entries, :doc_content_type, :doc_file_type
    rename_column :semi_static_entries, :img_content_type, :img_file_type
  end
end
