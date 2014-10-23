module SemiStatic
  class Photo < ActiveRecord::Base

    include ExpireCache
    include Elasticsearch
    include Elasticsearch::Model
    include Elasticsearch::Model::Callbacks
  
    index_name SemiStatic::Engine.config.site_name.gsub(/( )/, '_').downcase
  
    belongs_to :entry
  
    attr_accessible :title, :description, :img, :home_page, :position, :entry_id
    has_attached_file :img,
       :styles => {
         :micro=> "40x40#",
         :mini=> "96x96#",
         :small=> "148x>",
         :thumb=> "180x180#",
         :bar=> "304x>",
         :big=> "640x>"
       },
       :convert_options => { :micro => "-strip -gravity Center",
                             :mini => "-strip -gravity Center",
                             :small => "-strip",
                             :bar => "-strip -quality 80",
                             :thumb => "-strip -gravity Center -quality 80",
                             :big => "-strip"  }
  
    default_scope order(:position, :entry_id, :id)
    scope :home, where('home_page = ?', true)

    # Really need the .or method here, but it's not available so we do a little trick and 
    # use this to only find the next photo that is linked to the same entry and if it
    # returns nil we deal with this in the next() or prev() methods.
    scope :after, lambda {|p| order(:position, :id).where("position >= ?", p.position).where("id > ?", p.id).limit(1)}
    scope :before, lambda {|p| order(:position, :id).where("position <= ?", p.position).where("id < ?", p.id).limit(1)}

    after_save :expire_site_page_cache
    after_destroy :expire_site_page_cache
  
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
  
    # To create SEO friendly urls
    def to_param
      "#{id} #{title}".parameterize
    end

    def neighbours
      if entry.nil?
        [ Photo.before(self).first || Photo.last, Photo.after(self).first || Photo.first]
      else
        [ self.entry.photos.before(self).first || Photo.before(self).first || Photo.last, self.entry.photos.after(self).first || Photo.after(self).first || Photo.first]
      end
    end
  end
end
