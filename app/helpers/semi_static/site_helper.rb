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
  end
end
