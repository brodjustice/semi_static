class CreateSemiStaticFcols < ActiveRecord::Migration
  def change
    create_table :semi_static_fcols do |t|
      t.string :name
      t.integer :position, :default => 0
      t.text  :content, :default => nil
      t.string :locale, :default => 'en'

      t.timestamps
    end
  end
end
