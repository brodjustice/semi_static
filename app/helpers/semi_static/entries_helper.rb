module SemiStatic
  module EntriesHelper
    STYLE_CLASSES = ['normal', ' feint',  'flat',  'collapse', 'flat collapse', 'hard', 'highlight', 'wobble', 'dotted', 'tile', 'extra-padding', 'custom1', 'custom2', 'custom3']

    def youtube_video(id, width=640, height=360)
      link_id = id.split(',').first
      w = id.split(',')[1] || width
      h = id.split(',')[2] || height
      "<div class='yt_video'> <iframe width='#{w.to_s.squish}' height='#{h.to_s.squish}' src='//www.youtube.com/embed/#{link_id}?rel=0&amp;controls=0&amp;showinfo=0' allowfullscreen></iframe></div>".html_safe
    end

    def human_file_size(s)
      units = %w{b Kb Mb Gb Tb}
      e = (Math.log(s)/Math.log(1024)).floor
      s = "%.0f" % (s.to_f / 1024**e)
      s.sub(/\.?0*$/, units[e])
    end

    def entry_link_path(e)
      if e.link_to_tag && (controller_name != 'tags' || @summaries)
        feature_path(e.tag.slug)
      else
        entry_link(e)
      end
    end

    def alt_img_as_icon(e, force=false)
      if e.alt_img.present? && (force || !e.news_item)
        "<a href='#{entry_link(e)}'><img class='alt-img' src='#{e.alt_img.url}' alt='#{e.alt_img_file_name}'/></a>".html_safe
      else
        ''
      end
    end

    def entry_title_or_id(e)
      (e.merge_with_previous ? '--> ' : '') + (e.get_title || "##{e.id.to_s}")
    end

    def link_to_next_entry(entry, default_path = nil)
      if entry && (n = entry.next_entry)
        "<a href='#{entry_link(n)}' class='next-entry'>#{t('Next')}</a>".html_safe
      elsif default_path
        "<a href='#{default_path}' class='next-entry'>#{t('Next')}</a>".html_safe
      else
        "<div class='no-entry'></div>".html_safe
      end
    end

    def link_to_previous_entry(entry)
      return unless entry && (p = entry.previous_entry)
      "<a href='#{entry_link(p)}' class='previous-entry'>#{t('Previous')}</a>".html_safe
    end

    # Warning. If you remove the single space between <div ...> and <div ...> such that it is <div ...><div ...> you will get a
    # different layout. This is true for FF and Chrome. Maybe my basic HTML knowledge is poor, but I have no idea why this
    # space should make any difference
    def photo_thumbs(e)
       return if e.nil? || (photos = e.photos_including_master.thumb).empty?
       c = "<div class='gallery doc'> <div class='spacer_wrapper'> ".html_safe
       photos.each{|p|
         c += "<div class='photo nutshell'> <div class='spaced'> ".html_safe
         if p.popup
           c += link_to(image_tag(p.img.url(:mini), :title => "#{p.title} - #{truncate(p.description, :length => 50)}"), photo_path(p), :onclick => "semiStaticAJAX('#{photo_path(p, :format => :js, :popup => true)}'); return false;")
         else
           c += link_to image_tag(p.img.url(:mini), :title => "#{p.title} - #{truncate(p.description, :length => 50)}"), photo_path(p)
         end
         c += "</div> </div> ".html_safe
       }
       c += "</div> </div> ".html_safe
    end

    CAPTCHA_CODES = ['0353', '2004', '5433', '6615', '6995', '7764', '7888', '7960']

    def captcha
      code = CAPTCHA_CODES.sample
      image_tag("/assets/captchas/#{code}.jpg", 'data-code' => code, :class => 'captcha') + hidden_field_tag('comment[captcha_code]', code)
    end

    def photo_main(e, group_size = 2)
       return if (photos = e.photos_including_master.main).empty?
       c = "<div class='section'>"
       photos.in_groups_of(group_size).each{|g|
         c += '<div class="group">'
         g.each{|p|
           c += "<div class='col span_1_of_#{group_size.to_s}'>"
           p && (c+= semantic_photo(p, :boxpanel, e.show_image_titles))
           c += '</div>'
         }
         c += '</div>'
       }
       c += '</div>'
       c.html_safe
    end

    def sidebar_style(s)
      c = "background-color:#{s.bg_color};color:#{s.color};"
      if s.bg.present?
        c += "background-image: url(\'#{s.bg.url(:bar)}\');"
      end
      c
    end

    def semantic_product(e)
      return unless e.product.present?
      c = '<div class="product" vocab = "http://schema.org/" typeof="IndividualProduct"><table>'; p = e.product
      %w(name description color height depth width weight price).each{|prop|
        if prop == 'price' && p.price.present?
          c += "<tr property='offers'  typeof='Offer' class='row'><td>#{t('price')}: </td><td><span property='priceCurrency'>#{p.currency}</span><span property='price'>#{p.price}</span></td></tr>".html_safe
        elsif p.send(prop).present?
          c += "<tr class='row'><td>#{t(prop)}: </td><td><span property='#{prop}'>#{p.send(prop)}</span></td></tr>".html_safe
        end
      }
      c += '</table>'
      if p.entry.present?
        c += "<div class='group row'>Image URL: <a property='image' href='#{p.entry.img.url(:big)}'>#{request.base_url + p.entry.img.url(:big)}</a></div>".html_safe
      end
      c += '</div>'
      c.html_safe
    end
  end
end
