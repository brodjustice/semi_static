module SemiStatic
  class Seo < ActiveRecord::Base
    include ExpireCache

    attr_accessible :keywords, :title, :description
    belongs_to :seoable, polymorphic: true

    default_scope order('created_at DESC')

    scope :master, where(:master => true)

    before_save :set_locale
    after_save :expire_site_page_cache
    before_destroy :expire_site_page_cache

    def self.root(tag_id, locale)
      if tag_id
        tag = Tag.find_by_id(params[:tag_id]).first
      else
        tag = Tag.where('name = ? OR name = ?', 'Home', 'Root').where('locale = ?', locale.to_s).first
      end
      [tag, tag.nil? ? nil : tag.seo]
    end

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
