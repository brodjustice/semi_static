module SemiStatic
  class Product < ActiveRecord::Base
    attr_accessible :name, :description, :color, :height, :depth, :width, :weight, :price, :currency, :inventory_level

    belongs_to :entry, :dependent => :destroy

  end
end
