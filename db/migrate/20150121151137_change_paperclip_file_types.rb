class ChangePaperclipFileTypes < ActiveRecord::Migration
  def up
    add_column :semi_static_entries, :show_in_documents_tag, :boolean, :default => false
    rename_column :semi_static_entries, :doc_file_type, :doc_content_type
    rename_column :semi_static_entries, :img_file_type, :img_content_type
  end

  def down
    remove_column :semi_static_entries, :show_in_documents_tag
    rename_column :semi_static_entries, :doc_content_type, :doc_file_type
    rename_column :semi_static_entries, :img_content_type, :img_file_type
  end
end
