module SemiStatic
  class Banner < ActiveRecord::Base
    include Pages

    attr_accessible :name, :tag_line, :img

    has_many :entries
    has_many :tags

    THEME = {
      'tiles' => {:desktop => :desktop, :mobile => :mobile},
      'menu-right' => {:desktop => :desktopy500, :mobile => :mobile, :entry => :entry},
      'standard-2col-1col' => {:desktop => :desktop, :mobile => :mobile},
      'bannerette-2col-1col' => {:desktop => :desktop, :mobile => :mobile},
      'plain-3col' => {:desktop => :desktop, :mobile => :mobile},
      'parallax' => {:desktop => :parallax, :mobile => :parallax},
      'plain-big-banner-3col' => {:desktop => :desktopy500, :mobile => :mobiley500}
    }

    has_attached_file :img,
       :url => "/system/banners/:id/:style/:filename",
       :path => ":rails_root/public/system/banners/:id/:style/:filename",
       :styles => { :desktop=> "1500x300#",
                    :entry => "900x500#",
                    :mobile => "750x300#",
                    :parallax => "1000x>",
                    :desktopy500 => "1500x500>",
                    :mobiley500 => "750x500#" },
       :convert_options => { :desktop => "-strip -gravity Center -quality 80",
                             :entry => "-strip -gravity Center -quality 85" ,
                             :header => "-strip -gravity Center -quality 75" ,
                             :desktopy500 => "-strip -gravity Center -quality 75" ,
                             :mobiley500 => "-strip -gravity Center -quality 75" }

    validates_attachment_content_type :img, :content_type => ['image/jpeg', 'image/png', 'image/gif']

    after_save :expire_site_page_cache

    def img_url_for_theme(screen)
      img.url(THEME[SemiStatic::Engine.config.theme][screen])
    end

    def img_height(theme, screen)
      Paperclip::Geometry.from_file(Rails.root.to_s + '/public' + img(THEME[theme][screen])).height.to_i
    end
  end
end
