module SemiStatic
  class Product < ApplicationRecord
    belongs_to :entry, :optional => true

    has_many :order_items

    has_one_attached :img

    validates :price, :numericality => true, :allow_nil => false

  end
end
