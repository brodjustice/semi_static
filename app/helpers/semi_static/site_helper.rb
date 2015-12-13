module SemiStatic
  module SiteHelper

    PREDEFINED = {
      'Home' => SemiStatic::Engine.routes.url_helpers.home_path,
      'References' => SemiStatic::Engine.routes.url_helpers.references_path,
      'Contact' => SemiStatic::Engine.routes.url_helpers.new_contact_path,
      'Documents' => SemiStatic::Engine.routes.url_helpers.documents_path,
      'News' => nil,
      'Gallery' => SemiStatic::Engine.routes.url_helpers.photos_path
    }

    # Unless set, will default to 5
    MAX_MENU_TAGS = {
      'bannerless' => 10,
      'menu-right' => 10,
      'elegant' => 10,
      'standard-2col-1col' => 10
    }

    # For GET you should call this rather than entry_path so that entries
    # acting as tags can be intercepted
    def entry_link(e, options = {})
      if e.acts_as_tag_id
        SemiStatic::Engine.routes.url_helpers.feature_path(e.acts_as_tag.slug, options)
      else
        SemiStatic::Engine.routes.url_helpers.entry_path(e, options)
      end
    end

    def select_layout(obj)
      'semi_static_' + LAYOUTS[obj.layout_select || 0]
    end

    def max_menu_tags
      MAX_MENU_TAGS[SemiStatic::Engine.config.theme] || 5
    end

    def predefined_tags
      # This does not work in ruby 1.9.3, depending on exact version:
      #
      # PREDEFINED.merge(SemiStatic::Engine.config.predefined.merge(SemiStatic::Engine.config.predefined){|k, v| Rails.application.routes.url_helpers.send(*v)})
      PREDEFINED.merge(Hash[SemiStatic::Engine.config.predefined.map{|k, v| [k, Rails.application.routes.url_helpers.send(*v)]}])
    end

    def menu_from_tag(t)
      t.predefined_class.blank? ? semi_static.feature_path(t.slug) : "#{predefined_tags[t.predefined_class]}?tag_id=#{t.id}"
    end

    def hreflang_tags
      c = ''
      if SemiStatic::Engine.config.localeDomains.count > 1
        SemiStatic::Engine.config.localeDomains.keys.each{|k|
          c += "<link rel=\"alternate\" href=\"#{SemiStatic::Engine.config.localeDomains[k.to_s]}\" hreflang=\"#{k.to_s}\" />"
        }
      c.html_safe
      end
    end

    def construct_url(p, l)
      host = URI.parse(SemiStatic::Engine.config.localeDomains[l]).host
      if p.kind_of?(Tag)
        if p.predefined_class.present?
          SemiStatic::Engine.config.localeDomains[l] + PREDEFINED[p.predefined_class]
        else
          SemiStatic::Engine.routes.url_for(:controller => p.class.to_s.underscore.pluralize, :action => 'show', :slug => p.slug, :host => host)
        end
      elsif p.kind_of?(String)
        SemiStatic::Engine.config.localeDomains[l] + p
      else
        SemiStatic::Engine.routes.url_for(:controller => p.class.to_s.underscore.pluralize, :action => 'show', :id => p.to_param, :host => host)
      end
    end

    def entry_body(e)
      e.simple_text ? simple_format(e.body) : e.body.html_safe
    end

    def entry_summary(e, l = 300, news = false)
      if e.summary.blank? || (!news && e.use_as_news_summary)
        if e.simple_text
          simple_format(e.body[0..l] + '...')
        else
          truncate_html(e.body, :length => l) unless (l.nil? || (l < 1))
        end
      else
        simple_format(e.summary)
      end
    end

    # This allows us to deal with images that are smaller than expected. We set the max-width inline according
    # to the uploaded file size. This then stops the image from being displayed larger than the origional.
    def image_with_style(e, style, max_width, popup=true)
      if popup && e.image_popup
        c = "<a class='popable' onclick=\'semiStaticAJAX(\"#{entry_path(e, :format => :js, :popup => true)}\")\; return false;' href='#'> ".html_safe
      else
        c = ''
      end
      if max_width
        c += image_tag(e.img_url_for_theme(style, @side_bar), :style => "max-width: #{max_width.to_s + 'px'};").html_safe
      elsif !e.img_dimensions.blank?
        w = [e.img.styles[SemiStatic::Entry::THEME[SemiStatic::Engine.config.theme][style]].geometry.split('x').first.to_i, e.img_dimensions[0]].min
        c += image_tag(e.img_url_for_theme(style, @side_bar), :style => "max-width: #{w.to_s + 'px'};").html_safe
      else
        c += image_tag(e.img_url_for_theme(style, @side_bar)).html_safe
      end
      if popup && e.image_popup
        c += "</a>".html_safe
      end
      c.html_safe
    end

    def semantic_entry_image(e, style, max_width=nil, popup=true)
      c = '<figure vocab = "http://schema.org/" typeof="ImageObject"> '.html_safe
      sc = e.raw_title.blank? ? e.image_caption : e.raw_title
      c += "<meta  property='name' content='#{sc}'> ".html_safe
      c += "<div class='#{style.to_s} image_wrapper'>".html_safe
      c += image_with_style(e, style, max_width, popup)
      c += '</div>'.html_safe
      unless e.image_caption.blank? || style == :home
        c += "<figcaption class='caption'> <div class='caption-inner' property='description'>#{e.image_caption}</div> </figcaption> ".html_safe
      end
      c += '</figure>'.html_safe
    end

    def semantic_photo(p, style, show_title = true)
      c = '<figure vocab = "http://schema.org/" typeof="ImageObject"> '.html_safe
      if p.popup
        c += "<a class='popable' onclick=\'semiStaticAJAX(\"#{photo_path(p, :format => :js, :popup => true)}\")\; return false;' href='#{photo_path(p)}' class='photo'> ".html_safe
      else
        c += "<a href='#{photo_path(p)}' class='photo'> ".html_safe
      end
      if show_title
        c += "<h3 property='name'>#{p.title}</h3>".html_safe
      else
        c += "<meta property='name' content='#{p.title}'/>".html_safe
      end
      c += image_tag(p.img.url(style), :class => 'photo')
      c += '</a>'.html_safe
      unless p.description.blank?
        c += "<figcaption class='caption'> <div class='caption-inner' property='description'>#{p.description}</div> </figcaption> ".html_safe
      end
      c += '</figure>'.html_safe
    end

    def icon(tag)
      return '' if tag.nil?
      if Tag.use_sprites?
       "<div class='icon sprite mini' id=\"sprite_#{tag.position.to_s}\"></div>".html_safe
      elsif tag.icon_in_menu
       "<div class='icon'><img src=\"#{tag.icon.url(:standard)}\" alt=\"#{tag.title} icon\"/></div>".html_safe
      end
    end

    def switch_box_tag(name, value = "1", checked = false, options = {})
      html_options = { "type" => "checkbox", "name" => name, "id" => sanitize_to_id(name), "value" => value }.update(options.stringify_keys)
      html_options["checked"] = "checked" if checked
      '<div class="onoffswitch">'.html_safe +
      "<input type='checkbox' name='onoffswitch' class='onoffswitch-checkbox' id='#{html_options["id"]}' #{html_options["checked"]}><label class='onoffswitch-label' for='#{html_options["id"]}'>".html_safe +
      '<div class="onoffswitch-inner"></div><div class="onoffswitch-switch"></div></label></div>'.html_safe
    end
  
    # By default will show a flag icon for each alternate locale or translation. If flag is set to false it
    # will instead show each language symbol as 2 characters.
    def locales(flags=true)
      c = ''
      ls = (flags ? SemiStatic::Engine.config.localeDomains.reject{|k, v| k.to_s == I18n.locale.to_s} : SemiStatic::Engine.config.localeDomains)
      ls.each{|l, u|
        if u.downcase == 'translate'
          u = "http://translate.google.com/translate?hl=&sl=auto&tl=#{l}&u=#{url_encode(request.url)}"
        end
        if flags
          c+= "<li class='locale'><a href='#{u}'><img src='/assets/flags/#{l}.png' alt='#{l}'/></a></li>".html_safe
        else
          if session[:locale] == l
            c+= "<li class='locale selected'><a href='#{u}'>#{l}</a></li>".html_safe
          else
            c+= "<li class='locale'><a href='#{u}'>#{l}</a></li>".html_safe
          end
        end
      }
      c.html_safe
    end

    def home_custom
      if (t = Tag.where('predefined_class = ?', 'Home').where('locale = ?', locale).first).present? && t.partial_before_entries?
        render :partial => t.partial_path
      end
    end

    def home_custom_after
      if (t = Tag.where('predefined_class = ?', 'Home').where('locale = ?', locale).first).present? && t.partial_after_entries?
        render :partial => t.partial_path
      end
    end

    def page_footer
      #
      # Optimum layout is 4 columns, but we handle any
      # amount of columns
      #
      fcols = Fcol.locale(I18n.locale.to_s)
      c = ''
      if fcols.count == 4
        fcols.each_slice(2){|row|
          c += '<div class="col span_1_of_2_of_1_of_4">'.html_safe
          row.each{|fc|
            c += column(fc, 'span_1_of_2').html_safe
          }
          c += '</div>'.html_safe
        }
      else
        colclass = "span_1_of_#{fcols.count}"
        fcols.each{|fc|
          c += column(fc, colclass).html_safe
        }
      end
      c.html_safe
    end

    def semi_static_path_for_sign_in
      if defined?(CanCan)
        main_app.new_user_session_path
      else
        main_app.new_admin_session_path
      end
    end

    def semi_static_path_for_admins
      if defined?(CanCan)
        main_app.users_path
      else
        main_app.admins_path
      end
    end

    def semi_static_path_for_admin_session
      if defined?(CanCan)
        main_app.user_session_path
      else
        main_app.admin_session_path
      end
    end

    def seo_title
      if @seo
        @seo.title || @title || SemiStatic::Engine.config.site_name
      else
        @title || SemiStatic::Seo.master_title || SemiStatic::Engine.config.site_name
      end
    end

    def seo_description
      if @seo
        @seo.description || SemiStatic::Engine.config.site_name
      else
        SemiStatic::Seo.master_description || SemiStatic::Engine.config.site_name
      end
    end

    def seo_keywords
      (@seo && !@seo.keywords.blank?) ? @seo.keywords : t('keywords')
    end

    def seo_no_index?
      if @seo && @seo.no_index
        '<Meta Name="ROBOTS" Content="NOINDEX, NOFOLLOW">'.html_safe
      end
    end

    def og_image_url
      request.protocol + request.host + (@entry && @entry.img.present? ? @entry.img_url_for_theme : (SemiStatic::Engine.config.logo_image || ''))
    end

      # Create a video tag with fallback options as shown below.
    #
    # Notes:
    #   You should have a mp4 format video as first video in your array as this 
    # solves a known iPad bug but also as the first video is used for the fallback 
    # download option when flash is used.
    #   Currently IE9 (9.0.8112) will not show the poster unless you also have the
    # attribute  preload="none". A workaround would be to have the "poster" image
    # as the first frame of your mp4 video, or to have it set by javascript only
    # if IE is detected.
    #   This helper has 2 of it's own options
    # 1) "swf => true" - If this is set true AND there is a mp4 video source, then
    # a fallback flash player will be inserted. This may mean that your
    # page is no longer fully HTML5 compliant.
    # 2) "swf_poster" - This will be used instead of the video_tag poster if present.
    # This is sometimes required as the geometry of the video_tag may be different to
    # that of the flash player
    # 3) If you know what codecs will be required for your videos then you can make
    # them explicit by putting them in the v_params hash like this:
    #
    #
    # v_params = {
    #   ".mp4" => "type=\'video/mp4; codecs=\"avc1.42E01E, mp4a.40.2\"\'",
    #   ".webm" => "type=\'video/webm; codecs=\"vp8, vorbis\"\'",
    #   ".ogv" => "type=\'video/ogg; codecs=\"theora, vorbis\"\'"
    # }
    #
    # <video poster="video-clip.png" height=420 width=320 autoplay loop controls tabindex="0">
    #   <source src="/path/to/video.mp4" type='video/mp4; codecs="avc1.42E01E, mp4a.40.2"' />
    #   <source src="/path/to/video.webm" type='video/webm; codecs="vp8, vorbis"' />
    #   <source src="/path/to/video.ogv" type='video/ogg; codecs="theora, vorbis"' />
    #   <a href="video.webm">Video not supported by your browser. Click here to download the video.</a>.
    # <video>
    #
    # fallback_video_tag(["/system/attach/2/origional/video.mp4", "..."], {:autoplay => true, :size => "420x320"})
    #
    # Custom changes here are the additional play button (so 'controls' param should be ignored.)
    def fallback_video_tag(videos, options = {})
      v_params = {
        ".mp4" => "type=\'video/mp4\'",
        ".webm" => "type=\'video/webm\'",
        ".ogv" => "type=\'video/ogg\'"
      }
      options.symbolize_keys!
      options[:poster] = path_to_image(options[:poster]) if options[:poster]
      if size = options.delete(:size)
        options[:width], options[:height] = size.split("x") if size =~ %r{^\d+x\d+$}
      end
      videos = [ videos ] unless videos.is_a?(Array)
      if (options.delete(:swf) && v_swf = videos.select{|v| File.extname(v).split('?').first =~ /mp4/}).present?
        swf = fallback_swf_tag(v_swf, options.delete(:swf_poster) || options[:poster], :height => options[:height], :width => options[:width])
      end
      content_tag("video", options){
        videos.reduce(''){|c, v|
          if (v_type = File.extname(v).split('?').first) =~ /webm|ogv|mp4/
            c << "<source src=\"#{v}\" #{v_params[v_type]}/>"
          else
            c << ""
          end
        }.html_safe + raw(swf) + raw("<a href=#{videos.first}>#{_('BrowserVideoNotSupported')}</a>")
      }
    end

    def fallback_swf_tag(video, poster = nil, options = {})
      options.symbolize_keys!
      attrs = ""
      options.each_pair{|key, value| attrs << key.to_s + "=" + value.to_s + " "}
      swf = "/assets/video.swf"
      raw("<embed " + attrs) +
      raw("type = \"application/x-shockwave-flash\" src = #{swf} ") +
      raw("flashvars=\"file=#{video}&stretching=none&autostart=false&image=#{poster}\"/>")
    end

    def semi_static_path_for_admin_sign_out
      if SemiStatic::Engine.config.app_dashboard
        link_to 'Done', main_app.send(*SemiStatic::Engine.config.app_dashboard)
      else
        if defined?(CanCan)
          link_to 'Done', main_app.destroy_users_session_path, :method => :delete
        else
          link_to 'Done', main_app.destroy_admin_session_path, :method => :delete
        end
      end
    end

    #
    # Only used for parralax theme
    #
    def banner_skrollr_offset(banner)
      (banner.img_height(SemiStatic::Engine.config.theme, :desktop)/4 - 50).to_s
    end

    private

    def column(fc, colclass)
      c = "<div class='col #{colclass}'><div class='inner'>".html_safe
      c += "<h3>#{fc.name}</h3>".html_safe
      unless fc.content.blank?
        c += fc.content.html_safe
      end
      c += '<nav><ul>'.html_safe
      fc.links.each{|l|
        if l.new_window
          c += "<li><a href='#{l.url}' target='_blank'>#{l.name}</a></li>".html_safe
        else
          c += "<li><a href='#{l.url}'>#{l.name}</a></li>".html_safe
        end
      }
      c += '</ul></nav></div></div>'.html_safe
      c.html_safe
    end
  end
end
