module SemiStatic
  class Photo < ActiveRecord::Base

    include Pages
    include Elasticsearch
    include Elasticsearch::Model
    include Elasticsearch::Model::Callbacks
  
    index_name SemiStatic::Engine.config.site_name.gsub(/( )/, '_').downcase
  
    belongs_to :entry
    belongs_to :gallery
    has_one :seo, :as => :seoable
  
    attr_accessible :title, :description, :img, :home_page, :position, :entry_id, :gallery_id, :gallery_control, :locale, :popup, :hidden

    has_attached_file :img,
       :styles => {
         :micro=> "40x40#",
         :mini=> "96x96#",
         :small=> "148x>",
         :thumb=> "180x180#",
         :bar=> "304x>",
         :boxpanel=> "324x324#",
         :big=> "640x>",
         :compressed=> "100%x100%",
         :half=> "50%x50%"
       },
       :convert_options => { :micro => "-strip -gravity Center",
                             :mini => "-strip -gravity Center",
                             :small => "-strip",
                             :compressed => "-strip -quality 30",
                             :half => "-strip -quality 80",
                             :bar => "-strip -quality 80",
                             :boxpanel => "-strip -quality 80 -gravity Center",
                             :thumb => "-strip -gravity Center -quality 80",
                             :big => "-strip -quality 80"  }

    validates_attachment_content_type :img, :content_type => ['image/jpeg', 'image/png', 'image/gif']

    GALLERY_SYM = { :thumbs_and_sidebar => 1, :main => 2, :sidebar_only => 3, :invisible => 4 }
    GALLERY = GALLERY_SYM.invert
  
    # default_scope order(:position, :entry_id, :id)
    default_scope {order(:position, :entry_id, :id)}

    # scope :home, where('home_page = ?', true)
    scope :home, -> {where('home_page = ?', true)}

    # scope :thumb, where('gallery_control = ?', GALLERY_SYM[:thumbs_and_sidebar])
    scope :thumb, -> {where('gallery_control = ?', GALLERY_SYM[:thumbs_and_sidebar])}

    # This scope depricated, use the Photo hidden attribute instead
    # scope :not_invisible, where('gallery_control != ?', GALLERY_SYM[:invisible])
    scope :not_invisible, ~> {where('gallery_control != ?', GALLERY_SYM[:invisible])}

    # Scope is to select all visible photos from all galleries that are visible
    # scope :visible, joins(:gallery).where('semi_static_galleries.public = ?', true).where('hidden = ?', false)
    scope :visible, ~> {joins(:gallery).where('semi_static_galleries.public = ?', true).where('hidden = ?', false)}

    # Scope ignores if gallery is visible and looks only at photo hidden attribute
    scope :not_hidden, ~> {where('hidden = ?', false)}

    # scope :main, where('gallery_control = ?', GALLERY_SYM[:main])
    scope :main, -> {where('gallery_control = ?', GALLERY_SYM[:main])}

    # scope :sidebar, where('gallery_control=? OR gallery_control=?', GALLERY_SYM[:thumbs_and_sidebar], GALLERY_SYM[:sidebar_only])
    scope :sidebar, -> {where('gallery_control=? OR gallery_control=?', GALLERY_SYM[:thumbs_and_sidebar], GALLERY_SYM[:sidebar_only])}

    # scope :without_caption, where("description IS NULL or CAST(description as text) = ''")
    scope :without_caption, -> {where("description IS NULL or CAST(description as text) = ''")}

    # scope :locale, lambda {|locale| where("semi_static_photos.locale = ?", locale.to_s)}
    scope :locale, -> (locale) {where("semi_static_photos.locale = ?", locale.to_s)}

    # scope :without_gallery, where("gallery_id IS NULL")
    scope :without_gallery, ~> {where("gallery_id IS NULL")}

    # scope :for_tag_id, lambda {|tag_id| joins(:entry).where('semi_static_entries.tag_id = ?', tag_id)}
    scope :for_tag_id, ~> (tag_id) {joins(:entry).where('semi_static_entries.tag_id = ?', tag_id)}

    after_save :build_ordered_array
    after_destroy :build_ordered_array
    before_save :extract_dimensions

    serialize :img_dimensions
  
    # Really need the .or method for our scopes here, but it's not available so we would need to wrap this in a method,
    # but it turns out that Rails scopes don't deal correctly with ordering nil's. So we were doing
    # as below:
    #   scope :after, lambda {|p| order(:position, :id).where("position >= ?", p.position).where("id > ?", p.id).limit(1)}
    #   scope :before, lambda {|p| order(:position, :id).where("position <= ?", p.position).where("id < ?", p.id).limit(1)}
    #
    # And then the method looked like this:
    #
    #   def neighbours
    #     if entry.nil?
    #       [ Photo.before(self).first || Photo.last, Photo.after(self).first || Photo.first]
    #     else
    #       [ self.entry.photos.before(self).first || Photo.before(self).first || Photo.last, self.entry.photos.after(self).first || Photo.after(self).first || Photo.first]
    #     end
    #   end
    #
    # Now instead of this we build an ordered array of the photos (assuming we don't have thousands of photos):

    def build_ordered_array
      Photo.build_ordered_array
    end

    #
    # Ordered array is actually a hash of ordered arrays
    #
    # Looks like this { gallery_id => [id, id, id, .. id ], gallery_id => [id, id, id ... id]}
    #
    def self.build_ordered_array
      @@ids = {}.tap{|h| SemiStatic::Gallery.visible.each{|g| h[g.id] = g.photos.not_hidden.reorder(:position, :id).collect{|p| p.id }}}
    end

    # Currently have no support for admin_only viewable photos, so set as false
    def admin_only
      false
    end

    @@ids = build_ordered_array

    def neighbour_ids
      #
      # We used to ingnore the neighbour IDs if the gallery was not
      # public, like this:
      #   if self.gallery_id.nil? || self.gallery.nil? || !self.gallery.public
      # but the real meaning of Gallery.public is that the Gallery is not shown
      # on the Website Gallery page. If you want a photo to be hidden completely
      # then one should use the Photo.hidden attribute.
      #
      if self.gallery_id.nil? || self.gallery.nil?
        [ self.id, self.id ]
      else
        g = @@ids[self.gallery.id] || self.gallery.photos.not_hidden.collect{|g| g.id}
        pos = g.index(self.id)
        [ g[pos - 1] || g.last, g[pos + 1] || g.first]
      end
    end

    def self.search(query)
      __elasticsearch__.search(
        {
          query: {
            multi_match: {
              query: query,
              fuzziness: 1,
              fields: ['title^5', 'description']
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
  
    def tidy_dup
      new_photo = self.dup
      if File.file?(img.path)
        new_photo.img = self.img
      end
      new_photo.save
      new_photo
    end

    def raw_title
      title
    end

    # To create SEO friendly urls
    def to_param
      "#{id} #{title}".parameterize
    end

    private

    # Retrieves dimensions for image assets
    # Also used entry.rb
    def extract_dimensions
      tempfile = img.queued_for_write[:original]
      unless tempfile.nil?
        geometry = Paperclip::Geometry.from_file(tempfile)
        self.img_dimensions = [geometry.width.to_i, geometry.height.to_i]
      end
    end


  end
end
