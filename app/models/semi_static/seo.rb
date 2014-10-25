module SemiStatic
  class Seo < ActiveRecord::Base
    attr_accessible :keywords, :title, :description
    belongs_to :seoable, polymorphic: true

    default_scope order('created_at DESC')

    scope :master, where(:master => true)

    before_save :set_locale

    def self.new_from_master(seoable)
      if seoable.seo.nil?
        seo = seoable.seo = Seo.new(:title => seoable.title)
        unless (master = Seo.where(:master => true).first).nil?
          seo.keywords = master.keywords
          seo.description = master.description
        end
      end
      seoable.seo
    end

    def set_locale
      if self.locale.blank?
        self.locale = self.seoable.locale
      end
    end

    def to_master
      Seo.master.each{|s| s.master = false; s.save; }
      self.master = true
      self.save
    end
  end
end
