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

    scope :menu, -> {where('menu = ?', true)}
    scope :for_subscribers, -> {where('subscriber = ?', true)}
    scope :locale, -> (locale) {where("locale = ?", locale.to_s)}
    default_scope { order(:position) }

    scope :predefined, -> (locale, pre) { where("locale = ?", locale).where('predefined_class = ?', pre) }

    scope :with_attr, -> (attr){includes(:page_attrs).where(:page_attrs => {:attr_key => attr})}

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
    # So for Rails 4 there is no elegant solution available.
    #
    # In Rails 5 we get the 'or' method for our scope, so we might think we can do:
    #   scope :slide_menu, -> {where(:menu => true).or(includes(:page_attrs).where(:semi_static_page_attrs => {:attr_key => 'slideMenu'}))}
    # but this will not work because we get the error:
    #   "Relation passed to #or must be structurally compatible. Incompatible values: [:includes]"
    # This is thankfully fixed by simply having the 'include' in both sub-queries:
    #

    scope :slide_menu, -> {
      includes(:page_attrs).where(:menu => true).or(
        includes(:page_attrs).where(:semi_static_page_attrs => {:attr_key => 'slideMenu'})
      )
    }

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

    #
    # Build the public sitemap for the site, not to be confused with the SEO sitemap.xml.
    # Staring at the menu Tags, traverse down the heirachy to produce a sitemap. Important
    # to undestand that we start with the menu tags for a good reason, we assume that they
    # are the root tags. Other tags my appear as branches in the sitemap tree if an entry
    # with "acts_as_tag" set.
    #
    #
    def self.sitemap(locale)

      # Get only the menu Tags
      menu_tags = Tag.menu.locale(locale)

      # Build a sitemap based on those that are in the menu
      sm = SiteMapNode.new(
        nil,
        menu_tags.map{|t|
          SiteMapNode.new(t, nil, true)
        },
        true
      )

      # Get all the public tags, remove those that have "noindex set"
      tags = Tag.is_public.locale(locale).select{|t|
        t.seo.nil? || !t.seo.no_index
      }

      # Remove any of these tags that were are already in sitemap from menu Tags
      tags = tags.select{|t| !sm.include?(t)}

      # Add our menu tags back in
      tags = menu_tags + tags

      # Rebuild the full sitemap
      SiteMapNode.new(
        nil,
        tags.map{|t| SiteMapNode.new(t, nil, true)},
        true
      )
    end

    #
    # Construct a node in a sitemap. A node is actually a Tag. An Entry is an endpoint.
    # The "root" is the object with node_tag = nil
    #
    class SiteMapNode
      attr_accessor :node_tag, :entries, :nodes

      def initialize(node_tag, nodes, traverse = false)
        @node_tag = node_tag
        @entries = node_tag ? self.node_tag.entries.unmerged.not_linked_to_tag.select(&:indexable) : []
        @nodes = nodes

        # If the traverse is false, or the nodes are provided then
        # do not traverse. Note that a Tag never branches to another
        # Tag, it only branches to an Entry with Entry#acts_as_tag pointing
        # to the Tag that will be the new node.
        #
        @nodes = nodes || self.entries.select{|e| e.acts_as_tag}.map{|e|
          SiteMapNode.new(e.acts_as_tag, nil, traverse)
        }
      end

      #
      # It often useful to be able to reorder certain nodes, expecially at the top
      # level. For example you might want the "Home" to be first, even if it was
      # not the first in your menu (maybe to place it on the left).
      #
      # The array contains either ids or strings with the node/Tag name in the
      # required order eg. ['Home', 'About us', 'Blog']
      #
      def reorder(array)
        if array.first.kind_of?(String)
          original = self.nodes.map{|n| n.node_tag.name}
        else
          original = self.nodes.map{|n| n.node_tag.id}
        end

        # Create a array of the new order index positions
        new_order = array.map{|item| original.index(item)}.compact

        # Create an array of the items in the new positions
        rearranged_nodes = new_order.map { |index| self.nodes[index] }

        # Remove nodes from Sitemapnode by setting to nil and later compacting
        new_order.each{|i|
          self.nodes[i] = nil
        }

        # Add the rearranged nodes
        self.nodes = rearranged_nodes + self.nodes.compact

        self
      end

      #
      # Depth first search to discover if target Tag/node is in SiteMapNode and children
      #
      def include?(target, node=self)
        if node.node_tag == target
          return true
        end

        if node.nodes.empty?
          return false
        end

        node.nodes.each do |child_node|
          if child_node.include?(target)
            return true
          end
        end

        false
      end
    end
  end
end
