module SemiStatic
  class Banner < ApplicationRecord
    include Pages

    # 
    # For reference:
    #
    # attr_accessible :name, :tag_line, :img
    #

    has_many :entries
    has_many :tags
    has_many :newsletters

    THEME = {
      'tiles' => {:desktop => :desktop, :mobile => :mobile},
      'menu-right' => {:desktop => :desktopy500, :mobile => :mobile, :entry => :entry},
      'background-cover' => {:desktop => :desktopy500, :mobile => :mobile, :entry => :entry},
      'bannerless' => {:desktop => :desktopBig, :mobile => :mobileBig, :entry => :entry},
      'standard-2col-1col' => {:desktop => :desktop, :mobile => :mobile},
      'bannerette-2col-1col' => {:desktop => :bannerette, :mobile => :mobile},
      'elegant' => {:desktop => :desktopSmall, :mobile => :mobileSmall},
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
                    :backgroundx2 => "3200x>",
                    :background => "1600x>",
                    :parallax => "1000x>",
                    :desktopBg => "1400x>",
                    :tabletBg => "820x>",
                    :mobileBg => "580x>",
                    :bannerette => "1012x300#",
                    :desktopBig => "1400x350#",
                    :tabletBig => "820x350#",
                    :mobileBig => "580x350#",
                    :desktopSmall => "1000x150#",
                    :mobileSmall => "750x150#",
                    :desktopy500 => "1500x500>",
                    :mobiley500 => "750x500#" },
       :convert_options => { :desktop => "-strip -gravity Center -quality 80",
                             :entry => "-strip -gravity Center -quality 85" ,
                             :bannerette => "-strip -gravity Center -quality 80" ,
                             :header => "-strip -gravity Center -quality 75" ,
                             :parallax => "-strip -gravity Center -quality 75" ,
                             :background => "-strip -gravity Center -quality 70" ,
                             :backgroundx2 => "-strip -gravity Center -quality 30" ,
                             :desktopBg => "-strip -gravity Center -quality 70" ,
                             :tabletBg => "-strip -gravity Center -quality 70" ,
                             :mobileBg => "-strip -gravity Center -quality 70" ,
                             :desktopBig => "-strip -gravity Center -quality 70" ,
                             :tabletBig => "-strip -gravity Center -quality 70" ,
                             :mobileBig => "-strip -gravity Center -quality 70" ,
                             :desktopy500 => "-strip -gravity Center -quality 75" ,
                             :mobiley500 => "-strip -gravity Center -quality 75" }

    validates_attachment_content_type :img, :content_type => ['image/jpeg', 'image/png', 'image/gif']

    def img_url_for_theme(screen)
      img.url(THEME[SemiStatic::Engine.config.theme][screen])
    end

    def img_height(theme, screen)
      Paperclip::Geometry.from_file(Rails.root.to_s + '/public' + img(THEME[theme][screen])).height.to_i
    end
  end
end
