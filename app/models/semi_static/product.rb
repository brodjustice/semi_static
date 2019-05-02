module SemiStatic
  class Product < ApplicationRecord
    belongs_to :entry, :optional => true

    has_many :order_items

    validates :price, :numericality => true, :allow_nil => false

  end
end
