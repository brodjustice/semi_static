module SemiStatic
  class Entry < ActiveRecord::Base
    include ExpireCache
    include PartialControl
    include Elasticsearch::Model
    include Elasticsearch::Model::Callbacks
  
    index_name SemiStatic::Engine.config.site_name.gsub(/( )/, '_').downcase
  
    attr_accessible :title, :body, :tag_id, :home_page, :summary, :img, :news_item, :image_in_news
    attr_accessible :position, :doc, :doc_description, :summary_length, :locale, :style_class, :header_colour, :background_colour, :colour
    attr_accessible :banner_id, :partial, :entry_position, :master_entry_id, :youtube_id_str
    attr_accessible :side_bar, :side_bar_news, :side_bar_social, :side_bar_search, :unrestricted_html
  
    belongs_to :tag
  
    after_save :expire_site_page_cache
    before_destroy :expire_site_page_cache
  
    scope :home, where('home_page = ?', true)
    scope :news, where('news_item = ?', true)
    scope :locale, lambda {|locale| where("locale = ?", locale.to_s)}
    scope :not, lambda {|entry| where("id != ?", (entry ? entry.id : 0))}
  
    has_one :seo, :as => :seoable
    belongs_to :master_entry, :class_name => SemiStatic::Entry
    belongs_to :banner
    has_many :photos
    has_attached_file :doc
    has_attached_file :img,
       :styles => {
         :bar=> "304x>",
         :tile=> "241x>",
         :small=> "290x>",
         :panel=> "324x>",
         :medium => '443x>',
         :wide => '960x>',
         :big=> "750x>"
       },
       :convert_options => { :bar => "-strip -gravity Center -quality 80",
                             :tile => "-strip -gravity Center -quality 80",
                             :small => "-strip -gravity Center -quality 80",
                             :panel => "-strip -gravity Center -quality 80",
                             :medium => "-strip -gravity Center -quality 80",
                             :wide => "-strip -gravity Center -quality 80",
                             :big => "-strip -gravity Center -quality 85"  }
  
    DIRTY_TAGS= %w(span br em b i u ul ol li a div p img hr  h1 h2 h3 h4 iframe)
    DIRTY_ATTRIBUTES= %w(href class style id align src alt height width frameborder allowfullscreen)

    ALLOWED_TAGS= %w(span br em b i u ul ol li a div p img hr h1 h2 h3 h4)
    ALLOWED_ATTRIBUTES= %w(href src align alt)

    DISPLAY_ENTRY = {1 => :before, 2 => :after, 3 => :none}
    DISPLAY_ENTRY_SYM = DISPLAY_ENTRY.invert

    THEME = {
      'tiles' => {:desktop => :panel, :mobile => :panel, :small => :small, :summary => :tile, :show => :big},
      'menu-right' => {:desktop => :panel, :mobile => :panel, :small => :small, :summary => :medium, :show => :big},
      'standard-2col-1col' => {:desktop => :panel, :mobile => :panel, :summary => :panel, :show => :panel},
      'plain-3col' => {:desktop => :panel, :mobile => :panel, :summary => :panel, :show => :panel},
      'parallax' => {:desktop => :wide, :mobile => :panel, :summary => :panel, :show => :panel},
      'plain-big-banner-3col' => {:desktop => :panel, :mobile => :panel, :summary => :panel, :show => :panel}
    }

  
    default_scope order(:position)
    scope :additional_entries, lambda {|e| where('tag_id = ?', e.tag_id).where('id != ?', e.id)}

    def img_url_for_theme(screen = :desktop)
      screen = :summary if (screen == true)
      img.url(THEME[SemiStatic::Engine.config.theme][screen])
    end

    def self.search(query)
      __elasticsearch__.search(
        {
          query: {
            multi_match: {
              query: query,
              fuzziness: 1,
              fields: ['title^5', 'body']
            }
          },
          highlight: {
            pre_tags: ['<em class="label label-highlight">'],
            post_tags: ['</em>'],
            fields: {
              title:   { number_of_fragments: 0 },
              body: { fragment_size: 25 }
            }
          }
        }
      )
    end
  

    #
    # There is always discussion about if the HTML should be stripped and cleaned before or after saving to the DB. Most
    # believe that you should keep the origional and clean the HTML before you present it, since you then always have
    # a copy of the origional HTML. But this creates a much bigger load, cleaning every comment every time, that we
    # choose to clean the html before it goes in the DB.
    #
    def unrestricted_html=(val); 
      HTML::WhiteListSanitizer.allowed_protocols << 'data'
      if val == ('1' || 'true' || true)
        self.body = ActionController::Base.helpers.sanitize(self.body, :tags => DIRTY_TAGS, :attributes => DIRTY_ATTRIBUTES)
      else
        self.body = ActionController::Base.helpers.sanitize(self.body, :tags => ALLOWED_TAGS, :attributes => ALLOWED_ATTRIBUTES)
      end
      super
    end

    def youtube_id_str=(val)
      unless val.blank?
        val = val.split('/').last
        val = val.split('v=').last
      end
      super
    end

    # Might be a better way to do this with delegate...
    def photos_including_master
      self.master_entry.nil? ? self.photos : self.photos + self.master_entry.photos
    end
  
    # To create SEO friendly urls
    def to_param
      "#{id} #{title}".parameterize
    end
  end
end
