module SemiStatic
  class Role < ActiveRecord::Base
    attr_accessible :level, :name

    has_and_belongs_to_many :users, :join_table => :semi_static_role_users
  end
end
