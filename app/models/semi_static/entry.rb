module SemiStatic
  class Entry < ActiveRecord::Base
    include ExpireCache
    include PartialControl
    include Elasticsearch::Model
    include Elasticsearch::Model::Callbacks
  
    index_name SemiStatic::Engine.config.site_name.gsub(/( )/, '_').downcase
  
    attr_accessible :title, :body, :tag_id, :home_page, :summary, :img, :news_item, :image_in_news, :image_disable
    attr_accessible :position, :doc, :doc_description, :summary_length, :locale, :style_class, :header_colour, :background_colour, :colour
    attr_accessible :banner_id, :partial, :entry_position, :master_entry_id, :youtube_id_str
    attr_accessible :side_bar, :side_bar_news, :side_bar_social, :side_bar_search, :side_bar_gallery, :unrestricted_html, :merge_with_previous, :raw_html
    attr_accessible :facebook_share, :show_in_documents_tag, :image_caption, :tag_line
    attr_accessor :raw_html, :doc_delete, :img_delete

    settings index: { number_of_shards: 1, number_of_replicas: 1 }
  
    belongs_to :tag
  
    after_save :expire_site_page_cache
    after_save :check_for_newsletter_entry
    before_destroy :expire_site_page_cache
  
    scope :home, where('home_page = ?', true)
    scope :news, where('news_item = ?', true)
    scope :locale, lambda {|locale| where("locale = ?", locale.to_s)}
    scope :not, lambda {|entry| where("id != ?", (entry ? entry.id : 0))}
    scope :unmerged, where('merge_with_previous = ?', false)
    scope :exclude_newsletters, joins(:tag).where(:semi_static_tags => {:newsletter_id => nil})
    scope :for_newsletters, includes(:tag).where('semi_static_tags.newsletter_id IS NOT NULL')
    scope :for_documents_tag, where("show_in_documents_tag = ?", true)
  
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
  
    validates_attachment_content_type :doc, :content_type => ['image/jpeg', 'image/png', 'image/gif', 'application/pdf']

    DIRTY_TAGS= %w(style table tr td th span br em b i u ul ol li a div p img hr  h1 h2 h3 h4 iframe)
    DIRTY_ATTRIBUTES= %w(href class style id align src alt height width max-width frameborder allowfullscreen)

    ALLOWED_TAGS= %w(span br em b i u ul ol li a div p img hr h1 h2 h3 h4)
    ALLOWED_ATTRIBUTES= %w(href src align alt)

    DISPLAY_ENTRY = {1 => :before, 2 => :after, 3 => :none}
    DISPLAY_ENTRY_SYM = DISPLAY_ENTRY.invert

    THEME = {
      'tiles' => {:desktop => :panel, :mobile => :panel, :small => :small, :summary => :panel, :home => :tile, :show => :panel},
      'menu-right' => {:desktop => :panel, :mobile => :panel, :small => :small, :summary => :medium, :show => :big},
      'standard-2col-1col' => {:desktop => :panel, :mobile => :panel, :summary => :panel, :show => :panel},
      'bannerless' => {:desktop => :panel, :mobile => :panel, :summary => :panel, :show => :panel},
      'bannerette-2col-1col' => {:desktop => :panel, :mobile => :panel, :summary => :panel, :show => :panel},
      'plain-3col' => {:desktop => :panel, :mobile => :panel, :summary => :panel, :show => :panel},
      'parallax' => {:desktop => :wide, :mobile => :panel, :summary => :panel, :show => :panel},
      'plain-big-banner-3col' => {:desktop => :panel, :mobile => :panel, :summary => :panel, :show => :panel}
    }

    default_scope order(:position)
    scope :additional_entries, lambda {|e| where('tag_id = ?', e.tag_id).where('id != ?', e.id)}

    def as_indexed_json(options={})
      as_json(
        only: [:raw_title, :body, :effective_tag_line],
        methods: [:raw_title, :effective_tag_line]
      )
    end

    def new
      self.body = ''
      super
    end

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
              fields: ['raw_title^5', 'body', 'effective_tag_line^2']
            }
          },
          highlight: {
            pre_tags: ['<em class="label label-highlight">'],
            post_tags: ['</em>'],
            fields: {
              raw_title:   { number_of_fragments: 0 },
              effective_tag_line:   { number_of_fragments: 0 },
              body: { fragment_size: 25 }
            }
          }
        }
      )
    end
  
    def effective_tag_line
      tag_line || (banner.present? && banner.tag_line.present? ? banner.tag_line : nil )
    end

    def tidy_dup
      new_entry = self.dup
      new_entry.doc_delete = true
      new_entry.img_delete = true
      new_entry
    end

    def doc_delete=(val)
      if val == '1' || val == true
        self.doc.clear
      end
    end

    def img_delete=(val)
      if val == '1' || val == true
        self.img.clear
      end
    end

    def merged_main_entry_with_title
      if !self.title.blank? || !self.merge_with_previous
        self
      else
        tag_entries = self.tag.entries
        i = tag_entries.find_index{|e| e.id == self.id}
        while (i >= 0) do
          break unless tag_entries[i].merge_with_previous
          i = i - 1
        end
        return tag_entries[i]
      end
    end

    #
    # There is always discussion about if the HTML should be stripped and cleaned before or after saving to the DB. Most
    # believe that you should keep the origional and clean the HTML before you present it, since you then always have
    # a copy of the origional HTML. But this creates a much bigger load, cleaning every comment every time, that we
    # choose to clean the html before it goes in the DB.
    #
    def unrestricted_html=(val); 
      unless raw_html == true
        HTML::WhiteListSanitizer.allowed_protocols << 'data'
        if val == ('1' || 'true' || true)
          self.body = ActionController::Base.helpers.sanitize(self.body, :tags => DIRTY_TAGS, :attributes => DIRTY_ATTRIBUTES)
        else
          self.body = ActionController::Base.helpers.sanitize(self.body, :tags => ALLOWED_TAGS, :attributes => ALLOWED_ATTRIBUTES)
        end
      super
      end
    end

    # We allow the word break <wbr/> tag in the title for user control of long word breaking
    def title
      (t = super) ? t.html_safe : ''
    end

    def title=(t)
      t = ActionController::Base.helpers.sanitize(t, :tags => %w(wbr)) unless t.html_safe?
      super(t)
    end

    def raw_title
      ActionController::Base.helpers.strip_tags(title.gsub(/&shy;/, ''))
    end

    def explicit_title
      raw_title.blank? ? "-- #{self.merged_main_entry_with_title.raw_title} (#{self.position.to_s})" : raw_title
    end

    def raw_html=(val)
      if val == ('1' || 'true' || true)
        self.body = self.body
      end
    end

    def youtube_id_str=(val)
      unless val.blank?
        val = val.split('/').last
        val = val.split('v=').last
      end
      super
    end

    def next_merged_entry
      return nil if self.tag.nil?
      if (e = self.tag.entries[self.tag.entries.index(self) + 1])
        e.merge_with_previous ? e : nil
      end
    end

    def truncate?
      (summary.blank? ? body.size : summary.size) > summary_length
    end

    def check_for_newsletter_entry
      unless (n = self.tag.newsletter).nil?
        n.draft_entry_ids << self.id
        n.save
      end
    end

    def doc_mime_to_img
      'file_extension_' + (doc_content_type.blank? ? 'none' : doc_content_type.split('/').last.downcase) + '.png'
    end

    # Might be a better way to do this with delegate...
    def photos_including_master
      self.master_entry.nil? ? Photo.where(:entry_id => self.id) : Photo.where('entry_id=? OR entry_id=?', self.id, self.master_entry_id)
    end
  
    # To create SEO friendly urls
    def to_param
      "#{id} #{self.raw_title}".parameterize
    end
  end
end
