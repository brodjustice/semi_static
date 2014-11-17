module SemiStatic
  module SiteHelper
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
