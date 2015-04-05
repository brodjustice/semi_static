module SemiStatic
  module SiteHelper

    PREDEFINED = {
      'Home' => SemiStatic::Engine.routes.url_helpers.home_path,
      'References' => SemiStatic::Engine.routes.url_helpers.references_path,
      'Contact' => SemiStatic::Engine.routes.url_helpers.new_contact_path,
      'Documents' => SemiStatic::Engine.routes.url_helpers.documents_path,
      'Gallery' => SemiStatic::Engine.routes.url_helpers.photos_path
    }

    def predefined_tags
      # This does not work in ruby 1.9.3, depending on exact version:
      #
      # PREDEFINED.merge(SemiStatic::Engine.config.predefined.merge(SemiStatic::Engine.config.predefined){|k, v| Rails.application.routes.url_helpers.send(*v)})
      PREDEFINED.merge(Hash[SemiStatic::Engine.config.predefined.map{|k, v| [k, Rails.application.routes.url_helpers.send(*v)]}])
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

    def entry_summary(e, l = 300, news = false)
      if e.summary.blank? || (!news && e.use_as_news_summary)
        truncate_html(e.body, :length => l) unless (l < 1)
      else
        simple_format(e.summary)
      end
    end

    # This allows us to deal with images that are smaller than expected. We set the max-width inline according
    # to the uploaded file size. This then stops the image from being displayed larger than the origional.
    def image_with_style(e, style, max_width)
      if max_width
        image_tag(e.img_url_for_theme(style, @side_bar), :style => "max-width: #{max_width.to_s + 'px'};")
      elsif !e.img_dimensions.blank?
        w = [e.img.styles[SemiStatic::Entry::THEME[SemiStatic::Engine.config.theme][style]].geometry.split('x').first.to_i, e.img_dimensions[0]].min
        image_tag(e.img_url_for_theme(style, @side_bar), :style => "max-width: #{w.to_s + 'px'};")
      else
        image_tag(e.img_url_for_theme(style, @side_bar))
      end
    end

    def semantic_entry_image(e, style, max_width=nil)
      c = '<figure vocab = "http://schema.org/" typeof="ImageObject"> '.html_safe
      c += "<meta  property='name' content='#{e.raw_title}'> ".html_safe
      c += image_with_style(e, style, max_width)
      unless e.image_caption.blank? || style == :home
        c += "<figcaption class='caption'> <div class='caption-inner' property='description'>#{e.image_caption}</div> </figcaption> ".html_safe
      end
      c += '</figure>'.html_safe
    end

    def semantic_photo(p, style, show_title = true)
      c = '<figure vocab = "http://schema.org/" typeof="ImageObject"> '.html_safe
      c += "<a href='#{photo_path(p)}' class='photo'> ".html_safe
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
  
    def locales
      c = ''
      ls = SemiStatic::Engine.config.localeDomains.reject{|k, v| k.to_s == I18n.locale.to_s}
      ls.each{|l, u|
        if u.downcase == 'translate'
          u = "http://translate.google.com/translate?hl=&sl=auto&tl=#{l}&u=#{url_encode(request.url)}"
        end
        c+= "<li class='locale'><a href='#{u}'><img src='/assets/flags/#{l}.png' alt='#{l}'/></a></li>".html_safe
      }
      c.html_safe
    end

    def home_custom
      if (t = SemiStatic::Tag.locale(I18n.locale).find_by_name('Home')).present? && t.partial_before_entries?
        render :partial => t.partial_path
      end
    end

    def home_custom_after
      if (t = SemiStatic::Tag.locale(I18n.locale).find_by_name('Home')).present? && t.partial_after_entries?
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
      @seo && @seo.no_index && '<Meta Name="ROBOTS" Content="NOINDEX, NOFOLLOW">'.html_safe
    end

    def og_image_url
      request.protocol + request.host + (@entry && @entry.img.present? ? @entry.img_url_for_theme : SemiStatic::Engine.config.logo_image)
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
