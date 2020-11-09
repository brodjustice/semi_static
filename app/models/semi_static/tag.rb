module SemiStatic
  class Tag < ApplicationRecord
  
    include Pages
    include PartialControl
  
    # For when we don't know if its a Tag or Entry
    alias_attribute :explicit_title, :name

    has_one :seo, :as => :seoable, :dependent => :destroy
    belongs_to :use_entry_as_index, :class_name => 'SemiStatic::Entry', :optional => true
    has_many :page_attrs, :as => :page_attrable
    belongs_to :newsletter, :optional => true
    has_many :entries, :dependent => :destroy
    belongs_to :banner, :optional => true
    belongs_to :target_tag, :class_name => 'SemiStatic::Tag', :optional => true

    belongs_to :sidebar, :optional => true
    has_many :displays_as_side_bar, :foreign_key => :side_bar_tag_id, :class_name => 'SemiStatic::Tag'
    belongs_to :side_bar_tag, :foreign_key => :side_bar_tag_id, :class_name => 'SemiStatic::Tag', :optional => true

    has_and_belongs_to_many :href_equiv_tags, :join_table => :semi_static_tag_hreflang_tags,
      :class_name => 'SemiStatic::Tag', :association_foreign_key => :href_tag_id,
      :before_add => :check_href_equiv_tags

    validates :name, :uniqueness => {:scope => :locale}

    # scope :menu, where('menu = ?', true)
    scope :menu, -> {where('menu = ?', true)}

    # scope :for_subscribers, where('subscriber = ?', true)
    scope :for_subscribers, -> {where('subscriber = ?', true)}

    # scope :locale, lambda {|locale| where("locale = ?", locale.to_s)}
    scope :locale, -> (locale) {where("locale = ?", locale.to_s)}

    # default_scope order(:position)
    default_scope { order(:position) }

    # scope :predefined, lambda{|locale, pre| where("locale = ?", locale).where('predefined_class = ?', pre)}
    scope :predefined, -> (locale, pre) { where("locale = ?", locale).where('predefined_class = ?', pre) }

    # scope :with_attr, lambda{|attr| includes(:page_attrs).where('semi_static_page_attrs.attr_key  = ?', attr)}
    scope :with_attr, -> (attr){includes(:page_attrs).where(:page_attrs => {:attr_key => attr})}

    # scope :public, where("subscriber = ?", false).where("admin_only = ?", false)
    #
    # public becomes a reserved method in Rails 4
    #
    scope :is_public, -> {where("subscriber = ?", false).where("admin_only = ?", false)}
  
    before_save :generate_slug, :add_sidebar_title
  
    # 
    # This used to be a scope as Rails 3 allowed the following:
    #   scope :slide_menu, includes(:page_attrs).where('semi_static_page_attrs.attr_key = ? OR menu = ?', 'slideMenu', true)
    # so we expect we can use something like:
    #   scope :slide_menu, -> {includes(:page_attrs).where('semi_static_page_attrs.attr_key' = ? OR menu = ?', 'slideMenu', true)}
    # But this does not work in Rails 4. We can't use this:
    #  scope :slide_menu, -> {find_by_sql("SELECT \"semi_static_tags\".* FROM \"semi_static_tags\" 
    #    WHERE (semi_static_page_attrs.attr_key = 'slideMenu' OR menu = 't') ORDER BY position")}
    # because it returns an array.
    #
    # So in Rails 4 we could to use a method, but note that the 'merge' is a 'AND' operation not a UNION:
    #   def self.slide_menu
    #     self.where(:menu => true).merge(self.includes(:page_attrs).where(:semi_static_page_attrs => {:attr_key => 'slideMenu'}))
    #   end
    # So for Rails 4 there is no elegant solution at available.
    #
    # In Rails 5 we get the 'or' method for our scope, so we might think we can do:
    #   scope :slide_menu, -> {where(:menu => true).or(includes(:page_attrs).where(:semi_static_page_attrs => {:attr_key => 'slideMenu'}))}
    # but this will not work because we get the error:
    #   "Relation passed to #or must be structurally compatible. Incompatible values: [:includes]"
    # This is thankfully fixed by simply having the 'include' in both sub-queries:

    scope :slide_menu, -> {includes(:page_attrs).where(:menu => true).or(includes(:page_attrs).where(:semi_static_page_attrs => {:attr_key => 'slideMenu'}))}

    def title; name end
    def raw_title; name end
    def tag; self end

    #
    # Max number of entries before pagination starts
    #
    def paginate_at
      get_page_attr('pagination').to_i
    end

    def paginate?
      paginate_at > 0
    end

    def hreflang_tag_options
      Tag.where.not(:locale => (self.href_equiv_tags.map(&:locale) + [self.locale]))
    end

    #
    # The following should never happen, but just in case...
    #
    def check_href_equiv_tags(tag)
      # errors.add(:base, "Hreflang equiv for #{tag.locale} already present")
      self.href_equiv_tags.collect{|t| t.locale }.include?(tag.locale) && raise(ActiveRecord::Rollback)

      # errors.add(:base, "Hreflang equiv is itself!")
      (tag == self) && raise(ActiveRecord::Rollback)
    end

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

    def subscriber_content
      SemiStatic::Engine.config.try('subscribers_model') && self.subscriber
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

    #
    # If page_attr set get the specific entries for the sidebar navigation
    # else just get the default of all unmerged entries
    #
    def entries_for_navigation
      if (nav_entry_ids = self.get_page_attr('sideBarNavEntries')).present?
        nav_entry_ids.split(',').collect{|e| SemiStatic::Entry.find_by(:id => e)}.reject(&:blank?)
      elsif self.paginate?
        self.entries.unmerged[0..(self.paginate_at - 1)]
      else
        self.entries.unmerged
      end
    end
  end
end
