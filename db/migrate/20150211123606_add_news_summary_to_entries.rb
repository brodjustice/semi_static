class AddNewsSummaryToEntries < ActiveRecord::Migration
  def change
    add_column :semi_static_entries, :use_as_news_summary, :boolean, :default => false
  end
end
