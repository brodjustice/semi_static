class AddMaxImageAttachmentsToNewsletter < ActiveRecord::Migration
  def change
    add_column :semi_static_newsletters, :max_image_attachments, :integer, :default => 0
  end
end
