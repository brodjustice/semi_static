module SemiStatic
  class Seo < ApplicationRecord
    include Pages

    # 
    # For reference the attributes are as below. Now done with
    # stronge parameters in controller.
    #
    # attr_accessible :keywords, :title, :description, :no_index
    # attr_accessible :include_in_sitemap, :changefreq, :priority

    belongs_to :seoable, polymorphic: true
    has_many :hreflangs

    validates_length_of :description, maximum: 255

    CHANGE_FREQ = {
      :always => 0, :hourly => 1, :daily => 2,
      :weekly => 3, :monthly => 4, :yearly => 5,
      :never => 6, :unknown => 7
    }
    CHANGE_FREQ_SYMS = CHANGE_FREQ.invert

    default_scope { order('created_at DESC') }

    scope :master, -> { where(:master => true) }

    before_save :set_locale
    before_create :set_defaults

    def tag; seoable.tag end

    def set_defaults
      self.changefreq = CHANGE_FREQ[:unknown]
      if self.seoable.is_a?(Entry) && (self.seoable.acts_as_tag_id || self.seoable.link_to_tag || self.seoable.merge_with_previous)
        self.include_in_sitemap = false
        self.no_index = true
      end
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

    def self.root(tag_id, locale, name='Home')
      self.find_special(tag_id, locale, name)
    end

    def self.contact(tag_id, locale)
      self.find_special(tag_id, locale, 'Contact')
    end

    def set_locale
      if self.locale.blank?
        self.locale = self.seoable.locale
      end
    end

    private

    def self.find_special(tag_id, locale, name)
      if tag_id
        tag = Tag.find_by(:id => tag_id)
      else
        # See TagsHelper for Predefined Tags
        tag = Tag.where('predefined_class = ?', name).where('locale = ?', locale).first || Tag.find_by(:name => name)
      end
      [tag, tag.nil? ? nil : tag.seo]
    end
  end
end
