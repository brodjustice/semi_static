require 'elasticsearch/model'

module SemiStatic
  class Entry < ApplicationRecord
    include Pages
    include PartialControl
    include Elasticsearch::Model
    include Elasticsearch::Model::Callbacks
  
    index_name SemiStatic::Engine.config.site_name.gsub(/( )/, '_').downcase + Rails.env.to_s
  
    attr_accessor :merge_to_id, :doc_delete, :img_delete, :alt_img_delete, :notice, :change_main_entry_position

    # The news image is now also used for various alternative fuctions, icons, etc.
    alias_attribute :alt_img, :news_img
    alias_attribute :alt_img_file_name, :news_img_file_name

    #
    # A note on eleasticsearch: The search is configured to look in each Entry for a query match. Since
    # some entries may be merged Entries that are part of a bigger main Entry the score will represent
    # the bodies of entire collection of Entries that are merged into the main Entry (#full_body). However, we currently
    # do not concatinate the titles and sub-titles in the same way. This may be sub-optional.
    #
    settings index: { number_of_shards: 1, number_of_replicas: 0 }

    settings analysis: { analyzer: { semi_static: { tokenizer: 'standard', char_filter: 'html_strip' } } } do
      mappings dynamic: 'false' do
        indexes :full_body, type: :text, analyzer: 'semi_static'
        indexes :internal_search_keywords
        indexes :raw_title, type: :text
        indexes :locale
        indexes :effective_tag_line
      end
    end

    validates :tag_id, :presence => true
    validate :merge_to_id_exists?, :if => :merge_to_id

    belongs_to :tag
    belongs_to :acts_as_tag, :class_name => "SemiStatic::Tag", :optional => true
    has_many :provides_content_for_tags, :class_name => 'SemiStatic::Tag', :foreign_key => :use_entry_as_index, :inverse_of => :use_entry_as_index

    belongs_to :merged_entry, :class_name => "SemiStatic::Entry", :foreign_key => :merged_id, :optional => true
    has_one :up_merged_entry, :class_name => "SemiStatic::Entry", :foreign_key => :merged_id

    delegate :admin_only, to: :tag
  
    before_save :dup_master_id_photos
    after_save :check_for_newsletter_entry
    after_save :reindex_entry
    before_save :extract_dimensions
    after_save :check_merge_update
    before_destroy :check_merge_destroy

    serialize :img_dimensions
  
    scope :home, -> {where('home_page = ?', true)}

    scope :news, -> {where('news_item = ?', true)}

    scope :custom_view, -> {where.not(:partial => 'none')}

    scope :locale, -> (locale) {where("locale = ?", locale.to_s)}

    scope :not_admin_only, -> {includes(:tag).where(:semi_static_tags => {:admin_only => false})}

    scope :not, -> (entry) {where("id != ?", (entry ? entry.id : 0))}

    scope :has_style, -> (style){ where("style_class = ?", style)}
    scope :not_style, -> (style) { where("style_class != ?", style)}
    scope :has_seo, -> {includes(:seo).where(:semi_static_seos => {:seoable_type => 'SemiStatic::Entry'})}
    scope :has_page_attr, -> {includes(:page_attrs).where(:semi_static_page_attrs => {:page_attrable_type => 'SemiStatic::Entry'})}
    scope :without_seo, -> {includes(:seo).where(:semi_static_seos => {:seoable_type => nil})}

    scope :merged, -> {where('merge_with_previous = ?', true)}
    scope :unmerged, -> {where('merge_with_previous = ?', false)}

    scope :not_linked_to_tag, -> {where('link_to_tag = ?', false)}

    scope :exclude_newsletters, -> {joins(:tag).where(:semi_static_tags => {:newsletter_id => nil})}

    scope :for_newsletters, -> {includes(:tag).where.not(:semi_static_tags => {:newsletter_id => nil})}

    scope :for_documents_tag, -> {where("show_in_documents_tag = ?", true).where('doc_file_size IS NOT NULL')}

    scope :with_image, -> {where('img_file_name IS NOT NULL')}

    scope :without_image, -> {where('img_file_name IS NULL')}

    scope :with_attr, -> (attr){includes(:page_attrs).where(:semi_static_page_attrs => {:attr_key => attr})}

    has_one :seo, :as => :seoable, :dependent => :destroy
    has_many :page_attrs, :as => :page_attrable
    has_one :product
    has_one :click_ad
    belongs_to :sidebar, :optional => true
    belongs_to :master_entry, :class_name => 'SemiStatic::Entry', :optional => true
    belongs_to :banner, :optional => true
    belongs_to :gallery, :optional => true
    belongs_to :event, :optional => true
    belongs_to :job_posting, :optional => true
    belongs_to :squeeze, :optional => true
    has_many :photos
    has_many :comments, :dependent => :destroy

    belongs_to :side_bar_tag, :foreign_key => :side_bar_tag_id, :class_name => 'SemiStatic::Tag', :optional => true

    has_attached_file :doc

    has_attached_file :img,
       :styles => {
         :half => "50%x50%",
         :compressed => "100%x100%",
         :mini=> "96x96#",
         :thumb=> "180x180#",
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
                             :half => "-strip -quality 80",
                             :compressed => "-strip -quality 40",
                             :mini => "-strip -gravity Center -quality 80",
                             :small => "-strip -gravity Center -quality 80",
                             :panel => "-strip -gravity Center -quality 80",
                             :medium => "-strip -gravity Center -quality 80",
                             :twocol => "-strip -gravity Center -quality 70",
                             :wide => "-strip -gravity Center -quality 80",
                             :big => "-strip -gravity Center -quality 85"  }
  
    validates_attachment_content_type :doc, :content_type => ['image/jpeg', 'image/png', 'image/gif', 'application/pdf', 'application/zip', 'audio/mpeg']

    has_attached_file :news_img, :styles => {:bar => "304x>", :compressed => "100%x100%", :half => "50%x50%"},
      :convert_options => { :half => "-strip -quality 80", :compressed => "-strip -quality 40", :bar => "-strip -gravity Center -quality 80"}
    has_attached_file :newsletter_img, :styles => {:crop => "280x280#"}, :convert_options => { :crop => "-strip -gravity Center -quality 50"}

    DIRTY_TAGS= %w(style table tr td th span br em strong b i u ul ol li a div p img hr h1 h2 h3 h4 h5 h6 iframe)
    DIRTY_ATTRIBUTES= %w(title href class style id align src alt height width max-width frameborder allowfullscreen)

    ALLOWED_TAGS= %w(span div br em strong b i u ul ol li a div p img hr h1 h2 h3 h4 h5 h6)
    ALLOWED_ATTRIBUTES= %w(title href src align alt)

    COMMENT_STRATEGY = {:captcha_and_email_alert => 1, :open => 2}

    DISPLAY_ENTRY = {1 => :before, 2 => :after, 3 => :none, 4 => :inline}
    DISPLAY_ENTRY_SYM = DISPLAY_ENTRY.invert

    THEME = {
      'tiles' => {:desktop => :panel, :mobile => :panel, :summary => :panel, :home => :tile, :show => :panel},
      'menu-right' => {:desktop => :panel, :mobile => :panel, :summary => :panel, :home => :tile, :show => :panel},
      'background-cover' => {:desktop => :panel, :mobile => :panel, :summary => :panel, :home => :tile, :show => :panel},
      'standard-2col-1col' => {:desktop => :panel, :mobile => :panel, :summary => :panel, :show => :panel},
      'bannerless' => {:desktop => :panel, :mobile => :panel, :summary => :panel, :show => :panel},
      'bannerette-2col-1col' => {:desktop => :panel, :mobile => :panel, :summary => :panel, :show => :panel},
      'plain-3col' => {:desktop => :panel, :mobile => :panel, :summary => :panel, :show => :panel},
      'parallax' => {:desktop => :twocol, :mobile => :medium, :summary => :medium, :home => :tile, :show => :medium},
      'elegant' => {:desktop => :twocol, :mobile => :medium, :summary => :twocol, :home => :tile, :show => :twocol},
      'plain-big-banner-3col' => {:desktop => :panel, :mobile => :panel, :summary => :panel, :show => :panel}
    }

    default_scope {order(:position)}
    scope :additional_entries, -> (e){where('tag_id = ?', e.tag_id).where('id != ?', e.id)}

    #
    # If we are editing, we need to check if the merge_to_id attr_accessor needs setting
    #
    def merge_to_id
      @merge_to_id || up_merged_entry&.id
    end

    def internal_search_keywords
      self.get_page_attr('internalSearchKeywords')
    end

    def reindex_entry
      begin
        __elasticsearch__.index_document
      rescue => e
        self.notice = "WARNING: Elastic Search indexing responded: #{e}"
      end
    end

    def as_indexed_json(options={})
      self.as_json(
        only: [:full_body, :locale, :internal_search_keywords, :raw_title, :effective_tag_line],
        methods: [:full_body, :internal_search_keywords, :raw_title, :effective_tag_line]
      )
    end

    #
    # Can this be displayed by the search?
    #
    def indexable
      !self.admin_only &&
      !(self.seo && self.seo.no_index)
    end

    def get_title
      #
      # Return first non-blank string
      #
      (t = [title, sub_title, alt_title].reject(&:empty?).first).blank? ? false : t
    end

    #
    # Get title or even just the partial name if no title
    #
    def get_title_like
      (t = [title, sub_title, alt_title].reject(&:empty?).first).blank? ? false : t

      if t.blank?
        if self.partial != 'none'
          "[ #{partial} ]"
        else
          "[ ID: ##{self.id} <no title> ]"
        end
      else
        t
      end
    end

    #
    # Max number of entries before pagination starts
    #
    def paginate_at
      (get_page_attr('pagination') || self.tag.get_page_attr('pagination')).to_i
    end

    def paginate?
      paginate_at > 0
    end

    def menu_title
      self.alt_title.blank? ? title : alt_title
    end

    def subscriber_content
      SemiStatic::Engine.config.try('subscribers_model') && self.tag.subscriber
    end

    def img_url_for_theme(screen = :desktop, side_bar = true)
      screen = :summary if (screen == true)
      img.url(THEME[SemiStatic::Engine.config.theme][screen] || screen)
    end

    #
    # Some entries are not available as a full URL, most notibly merged entries. There is
    # a helper called entry_link() that works this out, so that you can
    # call it rather than entry_path(). 
    #
    # Method below is more elegant.
    #
    # If you pass the no_context it means that the Entry URL had no context slug in
    # the URL itself (ie. was of the form '/entries/:id-xxxxx') and so we test if it was
    # supposed to be context_url
    #
    # If the entry :provides_content_tags then it might not be canonical.
    # 
    def canonical(no_context = false)
      !self.merge_with_previous && !self.link_to_tag &&
        self.provides_content_for_tags.blank? &&
        !(no_context && self.tag.context_url.blank?) &&
        !self.acts_as_tag_id
    end

    #
    # Add the filter to only get the current locale else your results may include
    # non-functioning links other your website in other languages.
    #
    def self.search(query, locale='en')
      __elasticsearch__.search(
        {
          query: {
            bool: {
              must: [
                {
                  multi_match: {
                    query: query, 
                    fuzziness: 1,
                    fields: ['internal_search_keywords^100', 'raw_title^10', 'full_body', 'effective_tag_line']
                  }
                },
              ],
              filter: [
                {
                  term: { locale: locale }
                }
              ]
            }
          },
          highlight: {
            pre_tags: ['<em class="highlight">'],
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

    #
    # We need to catch certain errors that are caused when the electic search
    # gem cannot update the elasticsearch index, especially when in development
    # environment. So we wrap the method here.
    #
    def save
      begin
        super
      rescue Faraday::ConnectionFailed => e
        self.notice = "WARNING: Elastic Search indexing responded: #{e}"
      end
    end

    def destroy
      begin
        super
      rescue Faraday::ConnectionFailed => e
        self.notice = "WARNING: Elastic Search indexing responded: #{e}"
      end
    end

    def update_attributes(attrs)
      begin
        super
      rescue Faraday::ConnectionFailed => e
        self.notice = "WARNING: Elastic Search indexing responded: #{e}"
      end
    end
  
    def effective_tag_line
      tag_line || (banner.present? && banner.tag_line.present? ? banner.tag_line : nil )
    end

    def stripped_body
      ActionController::Base.helpers.strip_tags(self.body)
    end

    #
    # Called by before destroy. Sets the merge_id of mergee and, if needed, this Entry
    # and the merge chanined Entry
    #
    # If this is the main_entry, then *delete* the merge chain of entries
    #
    # If this a merged entry, link the chain back together
    #
    def check_merge_destroy
      if self.merged?
        self.up_merged_entry.update_columns(:merged_id => self.merged_id)
      else
        self.merged_entries.each{|e| e.delete}
      end
    end
    

    #
    # Called by after save. Sets the merge_id of mergee and, if needed, this Entry
    # and the merge chanined Entry
    #
    def check_merge_update
      previous_mergee = self.up_merged_entry

      if self.merge_to_id.present?

        mergee = Entry.find(self.merge_to_id.to_i)

        self.with_lock do

          if (previous_mergee && (previous_mergee.id != self.merge_to_id))
            #
            # This previously merged somewhere else in a merge chain, so
            # remove it from that place in the merge chain
            #
            mergee.update_columns(:merged_id => self.merged_id)
          end


          if mergee.merged_id != self.id
            #
            # This Entry is being newly merged into the chain
            #
            self.update_columns(:merged_id => mergee.merged_id)
            mergee.update_columns(:merged_id => self.id)

            self.update_columns(:tag_id => mergee.tag_id)
            self.update_columns(:locale => mergee.locale)

            # And finally, as it's still used sometimes instead of merged_id, set merge_with_previou
            self.update_columns(:merge_with_previous => true)
          end

        end

      else
        if previous_mergee.present?

          # This was previously a merged Entry but is now a main entry
          self.with_lock do
            previous_mergee.update_columns(:merged_id => self.merged_id)
            self.update_columns(:merged_id => nil)
          end

        end
        self.update_columns(:merge_with_previous => false)
      end
    end

    def tidy_dup
      new_entry = self.dup
      new_entry.img = self.img
      new_entry.doc = self.doc
      self.page_attrs.each{|pa|
        new_entry.page_attrs << SemiStatic::PageAttr.create(:attr_key => pa.attr_key, :attr_value => pa.attr_value)
      }
      new_entry.save
      new_entry
    end

    def dup_master_id_photos
      unless (e = Entry.find_by(:id => self.master_entry_id)).blank?
        e.photos.each{|p|
          photo = p.tidy_dup
          photo.locale = self.locale
          self.photos << photo
          photo.save
        }
        self.master_entry_id = nil
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

    def alt_img_delete=(val)
      if val == '1' || val == true
        self.news_img.clear
      end
    end

    def get_side_bar_entries
      if self.side_bar_tag.present?
        self.side_bar_tag.entries.unmerged.limit(20)
      else
        SemiStatic::Entry.news.limit(20).locale(self.tag.locale)
      end
    end

    #
    # It's a merged Entry there is an Entry with a merged_id pointing
    # to self
    #
    def merged?
      !self.up_merged_entry.nil?
    end

    def merge_with(e)
      e.merged_entry = self
      self.tag = e.tag; self.style_class = e.style_class
      self.position = e.position + 1; self.colour = e.colour; self.header_colour = e.header_colour
      self.locale = e.locale; self.background_colour = e.background_colour
      self.merge_with_previous = true
    end

    def merged_main_entry
      current = self
      loop do
        if current.up_merged_entry
          current = current.up_merged_entry
        else
          break current
        end
      end
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

    def full_body
      full_body_text = body
      unless self.merge_with_previous
        merged_main_entry.merged_entries.each{|e|
          full_body_text += body
        }
      end
      full_body_text
    end

    def merged_entries
      entries = []
      current_entry = self
      while (current_entry = current_entry.merged_entry)
        entries << current_entry
      end
      entries
    end

    def merged_entry_depth
      depth = 0
      while (current_entry = current_entry.merged_entry)
        depth =+ 1
      end
      depth
    end

    def next_merged_entry
      self.merged_entry
    end

    ##########################################################
    #
    # Legacy methods that return merged Entries based on their
    # position value rather than the merged_id column
    #
    def merged_entries_by_position
      entries = []
      unless (e = self.next_merged_entry_by_position).nil?
        entries << e
        while (e = e.next_merged_entry_by_position)
          entries << e
        end
      end
      entries
    end

    def merged_main_entry_by_position
      tag_entries = self.tag.entries
      i = tag_entries.find_index{|e| e.id == self.id}
      while (i >= 0) do
        break unless tag_entries[i].merge_with_previous
        i = i - 1
      end
      return tag_entries[i]
    end

    def next_merged_entry_by_position
      return nil if self.tag.nil?
      if (e = self.tag.entries[self.tag.entries.index(self) + 1])
        e.merge_with_previous ? e : nil
      end
    end

    def change_main_entry_position=(new_position)
      #
      # Only apply the method if this is the main Entry
      #
      unless self.merge_with_previous
        shift = new_position.to_i - self.position
        self.position = new_position.to_i
        self.merged_entries.each{|e|
          e.position = e.position + shift
        }
        self.save
        self.merged_entries.each{|e| e.save}
      else
        self.errors.add(:position, "Can only reposition the main entry")
      end
    end
    #
    # End of legacy merged entry methods
    #
    ##########################################################

    def truncate?
      (summary.present? && !use_as_news_summary) || (body.size > (summary_length || 0))
    end

    def check_for_newsletter_entry
      unless (n = self.tag.newsletter).nil?
        n.add_entry({:new_entry_id => self.id})
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

    #
    # Scopes that can be called by Ransack
    def self.ransackable_scopes(auth_object = nil)
      if auth_object.try(:admin?)
        # Admin user methods
        %i(merged unmerged with_image custom_view has_seo without_seo not_admin_only has_page_attr)
      else
        # others...
        %i(merged unmerged with_image custom_view has_seo without_seo not_admin_only has_page_attr)
      end
    end

    def merge_to_id_exists?
      if self.merge_to_id.present? && Entry.find_by(:id => self.merge_to_id).nil?
        errors.add(:base, "Cannot find Entry id #{self.merge_to_id} to merge to")
        throw(:abort)
      end
    end

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
