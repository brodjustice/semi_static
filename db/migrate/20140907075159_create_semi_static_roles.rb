class CreateSemiStaticRoles < ActiveRecord::Migration
  def up
    create_table :semi_static_roles do |t|
      t.string :name
      t.integer :level

      t.timestamps
    end

    create_table :semi_static_role_users, :id => false do |t|
      t.references :role, :user
    end
  end

  def down
    drop_table :semi_static_roles
    drop_table :semi_static_roles_users
  end
end
