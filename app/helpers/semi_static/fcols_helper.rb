module SemiStatic
  module FcolsHelper
    def page_footer
      #
      # Optimum layout is 4 columns, but we handle any
      # amount of columns
      #
      fcols = Fcol.locale(I18n.locale.to_s)
      c = ''
      if fcols.count == 4
        fcols.each_slice(2){|row|
          c += '<div class="col span_1_of_2_of_1_of_4"">'.html_safe
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
