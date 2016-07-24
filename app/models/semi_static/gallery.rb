module SemiStatic
  class Gallery < ActiveRecord::Base
    attr_accessible :title, :sub_title, :description, :public, :locale, :position

    has_many :photos
    has_many :entries

    scope :locale, lambda {|locale| where("locale = ?", locale.to_s)}
  end
end
