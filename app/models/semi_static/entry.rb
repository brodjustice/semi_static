module SemiStatic
  class Entry < ActiveRecord::Base
    include Pages
    include PartialControl
    include Elasticsearch::Model
    include Elasticsearch::Model::Callbacks
  
    index_name SemiStatic::Engine.config.site_name.gsub(/( )/, '_').downcase
  
    attr_accessible :title, :sub_title, :body, :tag_id, :home_page, :summary, :img, :news_item, :image_in_news, :image_disable, :news_img
    attr_accessible :position, :doc, :doc_description, :summary_length, :locale, :style_class, :header_colour, :background_colour, :colour
    attr_accessible :banner_id, :partial, :entry_position, :master_entry_id, :youtube_id_str, :use_as_news_summary, :simple_text
    attr_accessible :side_bar, :side_bar_news, :side_bar_social, :side_bar_search, :side_bar_gallery, :side_bar_tag_id, :unrestricted_html, :merge_with_previous, :raw_html
    attr_accessible :facebook_share, :show_in_documents_tag, :image_caption, :tag_line, :raw_html, :show_image_titles, :link_to_tag, :doc_delete, :layout_select
    attr_accessor :doc_delete, :img_delete

    settings index: { number_of_shards: 1, number_of_replicas: 1 }
  
    belongs_to :tag
  
    before_save :dup_master_id_photos
    after_save :expire_site_page_cache
    after_save :check_for_newsletter_entry
    before_destroy :expire_site_page_cache
    before_save :extract_dimensions

    serialize :img_dimensions
  
    scope :home, where('home_page = ?', true)
    scope :news, where('news_item = ?', true)
    scope :locale, lambda {|locale| where("locale = ?", locale.to_s)}
    scope :not, lambda {|entry| where("id != ?", (entry ? entry.id : 0))}
    scope :has_style, lambda {|style| where("style_class = ?", style)}
    scope :not_style, lambda {|style| where("style_class != ?", style)}
    scope :unmerged, where('merge_with_previous = ?', false)
    scope :not_linked_to_tag, where('link_to_tag = ?', false)
    scope :exclude_newsletters, joins(:tag).where(:semi_static_tags => {:newsletter_id => nil})
    scope :for_newsletters, includes(:tag).where('semi_static_tags.newsletter_id IS NOT NULL')
    scope :for_documents_tag, where("show_in_documents_tag = ?", true).where('doc_file_size IS NOT NULL')
    scope :with_image, where('img_file_name IS NOT NULL')
    scope :without_image, where('img_file_name IS NULL')
  
    has_one :seo, :as => :seoable
    has_one :product
    has_one :click_ad
    belongs_to :master_entry, :class_name => SemiStatic::Entry
    belongs_to :banner
    has_many :photos

    belongs_to :side_bar_tag, :foreign_key => :side_bar_tag_id, :class_name => 'SemiStatic::Tag'

    has_attached_file :doc

    has_attached_file :img,
       :styles => {
         :bar=> "304x>",
         :tile=> "241x>",
         :small=> "290x>",
         :panel=> "324x>",
         :medium => '443x>',
         :twocol => '661x>',
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

    has_attached_file :news_img, :styles => {:bar => "304x>"}, :convert_options => { :bar => "-strip -gravity Center -quality 80"}

    DIRTY_TAGS= %w(style table tr td th span br em b i u ul ol li a div p img hr  h1 h2 h3 h4 iframe)
    DIRTY_ATTRIBUTES= %w(href class style id align src alt height width max-width frameborder allowfullscreen)

    ALLOWED_TAGS= %w(span br em b i u ul ol li a div p img hr h1 h2 h3 h4)
    ALLOWED_ATTRIBUTES= %w(href src align alt)

    DISPLAY_ENTRY = {1 => :before, 2 => :after, 3 => :none, 4 => :inline}
    DISPLAY_ENTRY_SYM = DISPLAY_ENTRY.invert

    THEME = {
      'tiles' => {:bar => :bar, :desktop => :panel, :mobile => :panel, :small => :small, :summary => :panel, :home => :tile, :show => :panel, :medium => :medium, :tile => :tile},
      'menu-right' => {:bar => :bar, :desktop => :panel, :mobile => :panel, :small => :small, :summary => :panel, :home => :tile, :show => :panel, :medium => :medium},
      'standard-2col-1col' => {:bar => :bar, :desktop => :panel, :mobile => :panel, :summary => :panel, :show => :panel, :medium => :medium},
      'bannerless' => {:bar => :bar, :desktop => :panel, :mobile => :panel, :summary => :panel, :show => :panel, :medium => :medium, :tile => :tile},
      'bannerette-2col-1col' => {:bar => :bar, :desktop => :panel, :mobile => :panel, :summary => :panel, :show => :panel, :medium => :medium},
      'plain-3col' => {:bar => :bar, :desktop => :panel, :mobile => :panel, :summary => :panel, :show => :panel, :medium => :medium},
      'parallax' => {:bar => :bar, :desktop => :twocol, :mobile => :medium, :summary => :medium, :tile => :tile, :home => :tile, :show => :medium, :medium => :medium},
      'elegant' => {:bar => :bar, :desktop => :twocol, :mobile => :medium, :summary => :twocol, :tile => :tile, :home => :tile, :show => :twocol, :medium => :medium},
      'plain-big-banner-3col' => {:bar => :bar, :desktop => :panel, :mobile => :panel, :summary => :panel, :show => :panel, :medium => :medium}
    }

    default_scope order(:position)
    scope :additional_entries, lambda {|e| where('tag_id = ?', e.tag_id).where('id != ?', e.id)}

    def as_indexed_json(options={})
      as_json(
        only: [:raw_title, :body, :effective_tag_line],
        methods: [:raw_title, :effective_tag_line]
      )
    end

    def get_title
      return title unless title.blank?
      return sub_title unless sub_title.blank?
      false
    end

    def subscriber_content
      SemiStatic::Engine.config.try('subscribers_model') && self.tag.subscriber
    end

    def img_url_for_theme(screen = :desktop, side_bar = true)
      screen = :summary if (screen == true)
      # We assume a reasonable sized image (medium) should be served
      # if there is no side bar
      if !side_bar.nil? && !side_bar
        img.url(:medium)
      else
        img.url(THEME[SemiStatic::Engine.config.theme][screen])
      end
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
      new_entry.img = self.img
      new_entry.doc = self.doc
      new_entry.save
      new_entry
    end

    def dup_master_id_photos
      unless (e = Entry.find_by_id(self.master_entry_id)).blank?
        e.photos.each{|p|
          photo = p.tidy_dup
          photo.locale = self.locale
          self.photos << photo
          self.master_entry_id = nil
          photo.save
        }
      end
    end

    def next_entry
      self.tag.entries.select{|e| e.position > self.position}.first
    end

    def previous_entry
      self.tag.entries.select{|e| e.position < self.position}.last
    end

    def doc_delete=(val)
      if val == '1' || val == true
        self.doc.clear
        self.doc_description = nil
        self.show_in_documents_tag = false
      end
    end

    def img_delete=(val)
      if val == '1' || val == true
        self.img.clear
        self.image_caption = nil
      end
    end

    def get_side_bar_entries
      if self.side_bar_tag.present?
        self.side_bar_tag.entries.unmerged.limit(20)
      else
        SemiStatic::Entry.news.limit(20).locale(self.tag.locale)
      end
    end

    def merge_with(e)
      self.tag = e.tag; self.style_class = e.style_class
      self.position = e.position + 1; self.colour = e.colour; self.header_colour = e.header_colour
      self.locale = e.locale; self.background_colour = e.background_colour
      self.merge_with_previous = true
    end

    def merged_main_entry
      tag_entries = self.tag.entries
      i = tag_entries.find_index{|e| e.id == self.id}
      while (i >= 0) do
        break unless tag_entries[i].merge_with_previous
        i = i - 1
      end
      return tag_entries[i]
    end

    def merged_main_entry_with_title
      if !self.title.blank? || !self.merge_with_previous
        self
      else
        merged_main_entry
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

    def explicit_title(with_id = false)
      if with_id
        raw_title.blank? ? "-- #{self.merged_main_entry_with_title.raw_title} (##{self.id.to_s})" : "#{raw_title} (##{self.id.to_s})"
      else
        raw_title.blank? ? "-- #{self.merged_main_entry_with_title.raw_title} (#{self.position.to_s})" : raw_title
      end
    end

    def youtube_id_str=(val)
      unless val.blank?
        val = val.split('/').last
        val = val.split('v=').last
      end
      super
    end

    def merged_entries
      entries = []
      unless (e = self.next_merged_entry).nil?
        entries << e
        while (e = e.next_merged_entry)
          entries << e
        end
      end
      entries
    end

    def next_merged_entry
      return nil if self.tag.nil?
      if (e = self.tag.entries[self.tag.entries.index(self) + 1])
        e.merge_with_previous ? e : nil
      end
    end

    def truncate?
      (summary.present? && !use_as_news_summary) || (body.size > (summary_length || 0))
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

    private 

    # Retrieves dimensions for image assets
    def extract_dimensions
      tempfile = img.queued_for_write[:original]
      unless tempfile.nil?
        geometry = Paperclip::Geometry.from_file(tempfile)
        self.img_dimensions = [geometry.width.to_i, geometry.height.to_i]
      end
    end
  end
end
