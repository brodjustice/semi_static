module SemiStatic
  class Tag < ActiveRecord::Base
  
    include Pages
    include PartialControl
  
    attr_accessible :name, :menu, :position, :icon, :icon_in_menu, :icon_delete, :sidebar_title
    attr_accessible :predefined_class, :colour, :icon_resize, :locale, :max_entries_on_index_page
    attr_accessible :banner_id, :partial, :entry_position, :tag_line, :subscriber, :sidebar_id
    attr_accessible :side_bar, :side_bar_news, :side_bar_social, :side_bar_search, :side_bar_tag_id, :layout_select
    attr_accessible :target_tag_id, :target_name, :context_url
    attr_accessor :icon_delete
  
    has_one :seo, :as => :seoable
    has_many :page_attrs, :as => :page_attrable
    belongs_to :newsletter
    has_many :entries, :dependent => :destroy
    belongs_to :banner
    belongs_to :target_tag, :class_name => 'SemiStatic::Tag'

    belongs_to :sidebar
    has_many :displays_as_side_bar, :foreign_key => :side_bar_tag_id, :class_name => 'SemiStatic::Tag'
    belongs_to :side_bar_tag, :foreign_key => :side_bar_tag_id, :class_name => 'SemiStatic::Tag'

    validates :name, :uniqueness => {:scope => :locale}

    scope :menu, where('menu = ?', true)
    scope :for_subscribers, where('subscriber = ?', true)
    scope :locale, lambda {|locale| where("locale = ?", locale.to_s)}
    default_scope order(:position)
    scope :predefined, lambda{|locale, pre| where("locale = ?", locale).where('predefined_class = ?', pre)}
  
    before_save :generate_slug, :add_sidebar_title
    after_save :expire_site_page_cache
    before_destroy :expire_site_page_cache
  
    has_attached_file :icon,
       :styles => {
         :standard=> "48x48",
         :big => "96x96"
       },
       :convert_options => { :standard => "-strip -gravity Center",
                             :big => "-strip -gravity Center"  }
    after_commit :check_for_sprites_file

    def title; name end
    def raw_title; name end
    def tag; self end

    # This is just a scope, but if we define it as a scope it will break the migration since
    # it is called from config/routes.rb before the migration is complete
    def self.with_context_urls
      if self.column_names.include?('context_url')
        self.where('context_url = ?', true)
      else
        []
      end
    end

    def generate_slug
      self.slug = name.parameterize
    end

    def effective_tag_line
      tag_line || (banner.present? && banner.tag_line.present? ? banner.tag_line : nil )
    end
  
    def icon_delete=(val)
      if val == '1'
        self.icon.clear
      end
    end
  
    def self.use_sprites?
      !Tag.where('position = ?', 0).empty?
    end

    def get_side_bar_entries
      if self.side_bar_tag.present?
        self.side_bar_tag.entries.unmerged.limit(20)
      else
        SemiStatic::Entry.news.limit(20).locale(self.locale)
      end
    end
  
    def add_sidebar_title
      if self.sidebar_title.blank?
        self.sidebar_title = self.name
      end
    end

    def check_for_sprites_file
      if position == 0
        # Get extention and remove any query string if it exists, then add own
        # random query string for cache busting
        ext = File.extname(self.icon.url)
        base = File.basename(self.icon.url, ext)
  
        # The ext itself could have a query string which paperclip will have removed
        # Right now only png is valid
        ext = ext.split('?').first
  
        # Remove any previous sprites file
        FileUtils.rm_rf(Rails.root.to_s + '/public/system/icons/menu-sprites' +  '*')
  
        # Copy new sprite to know sprite path and add a query string
        new_ext = File.extname(self.icon.url).split('?').first
        FileUtils.cp((Rails.root.to_s + '/public' + self.icon.url.split('?').first).to_s, (Rails.root.to_s + '/public/system/icons/menu-sprites' + new_ext).to_s)
      end
    end
  end
end
