module SemiStatic
  module FcolsHelper
    def page_footer
      fcols = Fcol.locale(I18n.locale.to_s)
      colclass = "span_1_of_#{fcols.count}"
      c = ''
      fcols.each{|fc|
        c += "<div class='col #{colclass}'><div class='inner'>".html_safe
        c += "<h3>#{fc.name}</h3>".html_safe
        unless fc.content.blank?
          c += fc.content.html_safe
        end
        c += '<ul>'
        fc.links.each{|l|
          c += "<li><a href='#{l.url}'>#{l.name}</a></li>".html_safe
        }
        c += '</ul></div></div>'.html_safe
      }
      c.html_safe
    end
  end
end
