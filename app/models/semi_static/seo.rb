module SemiStatic
  class Seo < ActiveRecord::Base
    include Pages

    attr_accessible :keywords, :title, :description, :no_index
    attr_accessible :include_in_sitemap, :changefreq, :priority
    belongs_to :seoable, polymorphic: true

    CHANGE_FREQ = {
      :always => 0, :hourly => 1, :daily => 2,
      :weekly => 3, :monthly => 4, :yearly => 5,
      :never => 6, :unknown => 7
    }
    CHANGE_FREQ_SYMS = CHANGE_FREQ.invert

    default_scope order('created_at DESC')

    scope :master, where(:master => true)

    before_save :set_locale
    after_save :expire_site_page_cache
    before_destroy :expire_site_page_cache
    before_create :set_defaults

    def set_defaults
      self.changefreq = CHANGE_FREQ[:unknown]
    end

    def human_changefreq
      CHANGE_FREQ_SYMS[changefreq]
    end

    def self.references(tag_id, locale)
      self.find_special(tag_id, locale, 'References')
    end

    def self.photos(tag_id, locale)
      self.find_special(tag_id, locale, 'Gallery')
    end

    def self.root(tag_id, locale)
      tag = self.find_special(tag_id, locale, 'Home')
    end

    def self.new_from_master(seoable)
      if seoable.seo.nil?
        seo = seoable.seo = Seo.new(:title => seoable.raw_title)
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

    private

    def self.find_special(tag_id, locale, name)
      if tag_id
        tag = Tag.find_by_id(tag_id)
      else
        # See TagsHelper for Predefined Tags
        tag = Tag.where('predefined_class = ?', name).where('locale = ?', locale).first || Tag.find_by_name(name)
      end
      [tag, tag.nil? ? nil : tag.seo]
    end
  end
end
