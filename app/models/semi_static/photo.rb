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
                             :bar => "-strip",
                             :thumb => "-strip -gravity Center",
                             :big => "-strip"  }
  
    default_scope order(:position)
    scope :home, where('home_page = ?', true)
  
    after_save :expire_site_page_cache
  
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
  end
end
