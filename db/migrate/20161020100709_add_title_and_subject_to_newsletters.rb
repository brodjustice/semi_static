class AddTitleAndSubjectToNewsletters < ActiveRecord::Migration
  def change
    add_column :semi_static_newsletters, :title, :string
    add_column :semi_static_newsletters, :subject, :string
    add_column :semi_static_newsletters, :website_url, :string
  end
end
