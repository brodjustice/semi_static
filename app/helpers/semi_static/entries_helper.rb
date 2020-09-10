module SemiStatic
  module EntriesHelper
    STYLE_CLASSES = ['normal', ' feint',  'flat',  'collapse', 'flat collapse', 'hard', 'highlight', 'wobble', 'dotted', 'tile', 'extra-padding', 'custom1', 'custom2', 'custom3']

    #
    # The YouTube video id passed here can be in the form:
    #
    # '<youtube ID>, width, height'
    #
    # So if the width and height is not explicitly passed, then the id string is checked
    # for the dimensions. If that is also not present, then default dimensions of
    # 640 x 360 are used
    #
    # Since introduction of GDPR in the EU we use the YouTube Enable Privacy Mode which
    # basically means that the iframe is server from www.youtube-nocookie.com rather than
    # the standard www.youtube.com
    #
    def youtube_video(id, width=nil, height=nil, controls='0', loading='eager', autoplay=false)
      if autoplay 
        allow = 'allow="autoplay; encrypted-media; accelerometer"'
        controls = '1'
        autoplay_params = 'autoplay=1&amp;'
      else
        allow = 'allow="accelerometer"'
        autoplay_params = ''
      end
      link_id = id.split(',').first
      w = width || id.split(',')[1] || '640'
      h = height || id.split(',')[2] || '340'
      "<div class='yt_video'> <iframe loading='#{loading}' #{allow} width='#{w.to_s.squish}' height='#{h.to_s.squish}' src='https://www.youtube-nocookie.com/embed/#{link_id}?modestbranding=1&amp;rel=0&amp;#{autoplay_params}controls=#{controls}&amp;showinfo=0' allowfullscreen></iframe></div>".html_safe
    end

    def human_file_size(s)
      units = %w{b Kb Mb Gb Tb}
      e = (Math.log(s)/Math.log(1024)).floor
      s = "%.0f" % (s.to_f / 1024**e)
      s.sub(/\.?0*$/, units[e])
    end

    #
    # Document download ulr that triggers Google Analytics to record download event
    # If GA is not loaded then the _gap.push will fail, but this is no problem as
    # it will proceed directly to the download.
    #
    def link_to_doc_download(text, entry)
      "<a onclick='var that=this;ga(\"send\", \"event\", \"Download\", \"#{entry.doc.original_filename.parameterize}\");setTimeout(function(){location.href=that.href;},400);return false;' href='#{entry.doc.url}'>#{text}</a>".html_safe
    end

    #
    # Provide inline style, if any
    #
    def entry_inline_style(e)
      # (e.background_colour.present? && "background-color:#{e.background_colour};") + (e.colour.present? && "color:#{e.colour}")
      c = ''
      e.background_colour.present?  && c += "background-color:#{e.background_colour};"
      e.colour.present? && c += "color:#{e.colour};"
      c.present? ? c : false
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

    # Call this to include the Entry specific style. Can for example be called from
    # the Tag show if @link_to_tag is true
    def style_for_link_to_tag(entry)
      entry.style.present? && content_for(:header_css, entry.style)
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
      image_tag("captchas/#{code}.jpg", 'data-code' => code, :class => 'captcha') + hidden_field_tag('comment[captcha_code]', code)
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
      p = e.product
      c = "<a name='product_id_#{p.id}'}></a>"
      c += '<div class="product" vocab = "http://schema.org/" typeof="IndividualProduct"><div class="semiStaticOrderSummary"></div><table>'
      c += "<tr><td colspan=2><div class='semiStaticCartButton' id='semiStaticProductId_#{e.product.id}'></div><h2 property='name'>#{e.product.name}</h2></td></tr>".html_safe
      %w(description color height depth width weight price).each{|prop|
        if prop == 'price' && p.price.present?
          c += "<tr property='offers'  typeof='Offer' class='row'><td>#{t('price')}: </td><td><span property='priceCurrency'>#{p.currency} </span><span property='price'>#{p.price}</span></td></tr>".html_safe
        elsif p.send(prop).present?
          c += "<tr class='row'><td>#{t(prop)}: </td><td><span property='#{prop}'>#{p.send(prop)}</span></td></tr>".html_safe
        end
      }
      c += '</table>'
      if p.entry.present? && p.entry.img.present?
        c += "<div class='group row'>Image URL: <a property='image' href='#{p.entry.img.url(:big)}'>#{request.base_url + p.entry.img.url(:big)}</a></div>".html_safe
      end
      c += '</div>'
      c.html_safe
    end

    # Alpha version
    def video_popup_style(e)
      # "height: #{@entry.get_page_attr('youTubeVideoHeight') || '360px'}"
      'height: auto;'
    end

    #
    # Derives the inline type for double density popup image based on Photo(p) and pixel ratio (pr)
    # The weird thing is that the double density image is massively compressed, and so is not as
    # not as many Mbytes as half width (1/4 of the area) version. However, because of the extra pixel
    # density the image still renders better than the single density half width, 1/4 size, version
    #
    def popup_style(e, pr)
      unless e.img_dimensions.blank?
        pr = pr.round
        @width = e.img_dimensions.first.to_i/2
        @height = e.img_dimensions.last.to_i/2
        url = ((pr > 1.5) ? e.img.url(:compressed) : e.img.url(:half))
        "background-image: url(#{url}); background-size: cover; background-position: center center; width:#{@width}px; height:#{@height}px;"
      else
        "background: url(#{e.img.url}) center center no-repeat; background-size: cover;"
      end
    end
  end
end
