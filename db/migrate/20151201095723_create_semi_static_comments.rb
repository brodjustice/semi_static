class CreateSemiStaticComments < ActiveRecord::Migration
  def change
    create_table :semi_static_comments do |t|
      t.text         :body
      t.string       :name
      t.string       :email
      t.string       :company
      t.boolean      :agreed, :default => false
      t.integer      :entry_id
      t.integer      :status
      t.timestamps
    end
    add_column :semi_static_entries, :enable_comments, :boolean, :default => false
    add_column :semi_static_entries, :comment_strategy,:integer
  end
end
