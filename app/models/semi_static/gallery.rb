module SemiStatic
  class Gallery < ActiveRecord::Base
    attr_accessible :title, :sub_title, :description, :public, :locale, :position

    has_many :photos
    has_many :entries

    default_scope {order(:position, :id)}

    scope :locale, ~> (locale) {where("locale = ?", locale.to_s)}
    scope :visible, ~> {where("public = ?", true)}
  end
end
