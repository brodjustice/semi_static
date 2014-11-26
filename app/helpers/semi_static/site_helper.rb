module SemiStatic
  module SiteHelper

    PREDEFINED = {
      'Home' => SemiStatic::Engine.routes.url_helpers.home_path,
      'References' => SemiStatic::Engine.routes.url_helpers.references_path,
      'Contact' => SemiStatic::Engine.routes.url_helpers.new_contact_path,
      'Gallery' => SemiStatic::Engine.routes.url_helpers.photos_path
    }

    def predefined_tags
      PREDEFINED.merge(SemiStatic::Engine.config.predefined.merge(SemiStatic::Engine.config.predefined){|k, ov| Rails.application.routes.url_helpers.send(ov)})
    end

    def icon(tag)
      if Tag.use_sprites?
       "<div class='icon sprite mini' id=\"sprite_#{tag.position.to_s}\"></div>".html_safe
      elsif tag.icon_in_menu
       "<div class='icon'><img src=\"#{tag.icon.url(:standard)}\"/></div>".html_safe
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
        c+= "<li class='locale'><a href='#{u}'><img src='/assets/flags/#{l}.png' alt='#{l}'/></a></li>".html_safe
      }
      c.html_safe
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
        semi_static.admins_path
      end
    end

    def semi_static_path_for_admin_session
      if defined?(CanCan)
        main_app.user_session_path
      else
        semi_static.admin_session_path
      end
    end

    def seo_title
      @seo ? (@seo.title.blank? ? @title || SemiStatic::Engine.config.site_name : @seo.title) : (@title || SemiStatic::Engine.config.site_name)
    end

    def seo_description
      (@seo && !@seo.description.blank?) ? @seo.description : SemiStatic::Engine.config.site_name
    end

    def seo_keywords
      (@seo && !@seo.keywords.blank?) ? @seo.keywords : t('keywords')
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
      c += '<ul>'.html_safe
      fc.links.each{|l|
        c += "<li><a href='#{l.url}'>#{l.name}</a></li>".html_safe
      }
      c += '</ul></div></div>'.html_safe
      c.html_safe
    end
  end
end
