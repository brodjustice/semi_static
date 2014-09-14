class CreateSemiStaticUsers < ActiveRecord::Migration
  def change
    create_table :semi_static_users do |t|
      t.string :name
      t.string :surname

      t.timestamps
    end
  end
end
