module SemiStatic
  class Entry < ActiveRecord::Base
    include ExpireCache
    include Elasticsearch::Model
    include Elasticsearch::Model::Callbacks
  
    index_name SemiStatic::Engine.config.site_name.gsub(/( )/, '_').downcase
  
    attr_accessible :title, :body, :tag_id, :home_page, :summary, :img, :news_item, :image_in_news
    attr_accessible :position, :doc, :doc_description, :summary_length, :locale, :style_class, :header_colour, :background_colour, :colour
    attr_accessible :banner_id
    attr_accessible :side_bar, :side_bar_news, :side_bar_social, :side_bar_search
  
    belongs_to :tag
  
    before_save :clean_html
    after_save :expire_site_page_cache
    before_destroy :expire_site_page_cache
  
    scope :home, where('home_page = ?', true)
    scope :news, where('news_item = ?', true)
    scope :locale, lambda {|locale| where("locale = ?", locale.to_s)}
    scope :not, lambda {|entry| where("id != ?", (entry ? entry.id : 0))}
  
    belongs_to :banner
    has_many :photos
    has_attached_file :doc
    has_attached_file :img,
       :styles => {
         :bar=> "304x>",
         :panel=> "324x>",
         :big=> "500x>"
       },
       :convert_options => { :panel => "-strip -gravity Center -quality 80",
                             :big => "-strip -gravity Center -quality 80"  }
  
    ALLOWED_TAGS= %w(span br em b i u ul ol li a div p img hr)
    ALLOWED_ATTRIBUTES= %w(href style id align src alt)
  
    default_scope order(:position)
    scope :additional_entries, lambda {|e| where('tag_id = ?', e.tag_id).where('id != ?', e.id)}
  
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
    def clean_html
      HTML::WhiteListSanitizer.allowed_protocols << 'data'
      self.body = ActionController::Base.helpers.sanitize(self.body, :tags => ALLOWED_TAGS, :attributes => ALLOWED_ATTRIBUTES)
    end
  
    # To create SEO friendly urls
    def to_param
      "#{id} #{title}".parameterize
    end
  end
end
