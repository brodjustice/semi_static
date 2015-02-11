module SemiStatic
  module EntriesHelper
    STYLE_CLASSES = ['normal', ' feint',  'flat',  'collapse', 'flat collapse', 'hard', 'highlight', 'wobble', 'dotted']

    def youtube_video(id)
      "<div class='yt_video'> <iframe width='640' height='360' src='//www.youtube.com/embed/#{id}?rel=0&amp;controls=0&amp;showinfo=0' allowfullscreen></iframe></div>".html_safe
    end

    def human_file_size(s)
      units = %w{b Kb Mb Gb Tb}
      e = (Math.log(s)/Math.log(1024)).floor
      s = "%.0f" % (s.to_f / 1024**e)
      s.sub(/\.?0*$/, units[e])
    end

    # Warning. If you remove the single space between <div ...> and <div ...> such that it is <div ...><div ...> you will get a
    # different layout. This is true for FF and Chrome. Maybe my basic HTML knowledge is poor, but I have no idea why this
    # space should make any difference
    def photo_thumbs(e)
       return if (photos = e.photos_including_master.thumb).empty?
       c = "<div class='gallery doc'> <div class='spacer_wrapper'> ".html_safe
       photos.each{|p|
         c += "<div class='photo nutshell'> <div class='spaced'> ".html_safe
         c += link_to image_tag(p.img.url(:mini), :title => "#{p.title} - #{truncate(p.description, :length => 50)}"), photo_path(p)
         c += "</div> </div> ".html_safe
       }
       c += "</div> </div> ".html_safe
    end

    def photo_main(e)
       return if (photos = e.photos_including_master.main).empty?
       c = ''
       photos.in_groups_of(2).each{|g|
         c += '<div class="group">'
         g.each{|p|
           c += '<div class="col span_1_of_2">'
           p && (c+= semantic_photo(p, :boxpanel, e.show_image_titles))
           c += '</div>'
         }
         c += '</div>'
       }
       c.html_safe
    end

    def semantic_product(e)
      return unless e.product.present?
      c = '<div class="product" vocab = "http://schema.org/" typeof="IndividualProduct"><table>'; p = e.product
      %w(name description color height depth width weight price inventory_level).each{|prop|
        if prop == 'price' && p.price.present?
          c += "<tr property='offers'  typeof='Offer' class='row'><td>#{t('price')}: </td><td><span property='priceCurrency'>#{p.currency}</span><span property='price'>#{p.price}</span></td></tr>".html_safe
        elsif p.send(prop).present?
          c += "<tr class='row'><td>#{t(prop)}: </td><td><span property='#{prop}'>#{p.send(prop)}</span></td></tr>".html_safe
        end
      }
      c += '</table>'
      if p.entry.present?
        c += "<div class='group row'>Image URL: <a property='image' href='#{p.entry.img.url(:big)}'>#{request.url + p.entry.img.url(:big)}</a></div>".html_safe
      end
      c += '</div>'
      c.html_safe
    end
  end
end
