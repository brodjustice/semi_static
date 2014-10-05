module SemiStatic
  class Tag < ActiveRecord::Base
  
    include ExpireCache
  
    attr_accessible :name, :menu, :position, :icon, :icon_in_menu, :icon_delete, :sidebar_title
    attr_accessible :predefined_class, :colour, :icon_resize, :locale, :max_entries_on_index_page
    attr_accessible :banner_id
    attr_accessor :icon_delete
  
    has_many :entries, :dependent => :destroy
    belongs_to :banner

    accepts_nested_attributes_for :banner, :allow_destroy => true
  
    scope :menu, where('menu = ?', true)
    scope :locale, lambda {|locale| where("locale = ?", locale.to_s)}
    default_scope order(:position)
  
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
  
    def generate_slug
      self.slug = name.parameterize
    end
  
    def icon_delete=(val)
      if val == '1'
        self.icon.clear
      end
    end
  
    def self.use_sprites?
      !Tag.where('position = ?', 0).empty?
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
