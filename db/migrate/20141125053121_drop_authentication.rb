class DropAuthentication < ActiveRecord::Migration
  def up
    if ActiveRecord::Base.connection.table_exists? 'semi_static_users'
      drop_table :semi_static_users
    end
    if ActiveRecord::Base.connection.table_exists? 'semi_static_roles'
      drop_table :semi_static_roles
    end
  end

  def down
  end
end
