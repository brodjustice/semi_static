module SemiStatic
  class Customer < ApplicationRecord
    has_many :orders

    validates_presence_of :email, :name, :surname    
  end
end
