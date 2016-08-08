module SemiStatic
  class Fcol < ActiveRecord::Base
    include Pages
  
    ALLOWED_TAGS= %w(span br em b ul ol li a div p img hr)
    ALLOWED_ATTRIBUTES= %w(href style id align src alt)
  
    attr_accessible :name, :position, :content, :locale
  
    has_many :links, :dependent => :destroy
  
    default_scope :order => 'position ASC'
  
    scope :locale, lambda {|locale| where("locale = ?", locale.to_s)}
  
    #
    # There is always discussion about if the HTML should be stripped and cleaned before or after saving to the DB. Most
    # believe that you should keep the origional and clean the HTML before you present it, since you then always have
    # a copy of the origional HTML. But this creates a much bigger load, cleaning every comment every time, that we
    # choose to clean the html before it goes in the DB.
    #
    def clean_html
      HTML::WhiteListSanitizer.allowed_protocols << 'data'
      self.content = ActionController::Base.helpers.sanitize(self.body, :tags => ALLOWED_TAGS, :attributes => ALLOWED_ATTRIBUTES)
    end
  end
end
