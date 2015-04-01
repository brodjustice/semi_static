module SemiStatic
  class Photo < ActiveRecord::Base

    include Pages
    include Elasticsearch
    include Elasticsearch::Model
    include Elasticsearch::Model::Callbacks
  
    index_name SemiStatic::Engine.config.site_name.gsub(/( )/, '_').downcase
  
    belongs_to :entry
    has_one :seo, :as => :seoable
  
    attr_accessible :title, :description, :img, :home_page, :position, :entry_id, :gallery_control, :locale

    has_attached_file :img,
       :styles => {
         :micro=> "40x40#",
         :mini=> "96x96#",
         :small=> "148x>",
         :thumb=> "180x180#",
         :bar=> "304x>",
         :boxpanel=> "324x324#",
         :big=> "640x>"
       },
       :convert_options => { :micro => "-strip -gravity Center",
                             :mini => "-strip -gravity Center",
                             :small => "-strip",
                             :bar => "-strip -quality 80",
                             :boxpanel => "-strip -quality 80 -gravity Center",
                             :thumb => "-strip -gravity Center -quality 80",
                             :big => "-strip"  }

    validates_attachment_content_type :img, :content_type => ['image/jpeg', 'image/png', 'image/gif']

    GALLERY_SYM = { :thumbs_and_sidebar => 1, :main => 2, :sidebar_only => 3, :invisible => 4 }
    GALLERY = GALLERY_SYM.invert
  
    default_scope order(:position, :entry_id, :id)
    scope :home, where('home_page = ?', true)
    scope :thumb, where('gallery_control = ?', GALLERY_SYM[:thumbs_and_sidebar])
    scope :main, where('gallery_control = ?', GALLERY_SYM[:main])
    scope :sidebar, where('gallery_control=? OR gallery_control=?', GALLERY_SYM[:thumbs_and_sidebar], GALLERY_SYM[:sidebar_only])
    scope :without_caption, where("description IS NULL or CAST(description as text) = ''")
    scope :locale, lambda {|locale| where("locale = ?", locale.to_s)}

    after_save :expire_site_page_cache, :build_ordered_array
    after_destroy :expire_site_page_cache, :build_ordered_array
  
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

    def self.build_ordered_array
      @@ids = Photo.reorder(:entry_id, :position, :id).collect{|p| p.id}
    end

    @@ids = build_ordered_array

    def neighbour_ids
      pos = @@ids.index(self.id)
      [ @@ids[pos - 1] || @@ids.last, @@ids[pos + 1] || @@ids.first]
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

  end
end
