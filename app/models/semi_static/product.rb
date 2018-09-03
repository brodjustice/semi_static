module SemiStatic
  class Product < ActiveRecord::Base

    # For reference
    #
    # attr_accessible :name, :description, :color, :height, :depth, :width, :weight, :price, :currency, :inventory_level, :entry_id

    belongs_to :entry, :dependent => :destroy

  end
end
