# encoding: utf-8

module SemiStatic
  module SiteHelper

    def predefined_route(route_name=nil)
      routes = {
        'Home' => semi_static.root_path,
        'References' => semi_static.references_path,
        'Contact' => semi_static.new_contact_path,
        'Documents' => semi_static.documents_path,
        'News' => nil,
        'Imprint-credits' => '/site/imprint-credits',
        'Gallery' => semi_static.photos_path
      } 
      route_name ? routes[route_name] : routes
    end

    # There are quite a number of situations where the sidebar navigation menu is not required.
    # They are if:
    #   1) No Tag exists
    #   2) It is a link_to_tag page, i.e. an entry replacing a Tag 'index of Entries' page
    #   3) It is the pre-defined 'Gallery'
    #
    def side_bar_nav?
      !(@tag.nil? || @tag.entries.first.try(:link_to_tag) || @tag.predefined_class == "Gallery")
    end

    def entry_title(e, linked = false, h_tag = :h1, h_sub_tag = :h2)
      c = ''.html_safe

      #
      # If the page_attr 'entryIconGalleryId' exists, then use the image
      # as a icon before, or depending of CSS, to the left of the
      # header title. As the the page_attr name suggests, this should be
      # the ID of an image from the photo gallery. You will need to size
      # the image yourself, the standard being 64px by 64px, but you can
      # adjust this yourself with different image sizes and different CSS.
      #
      if e.get_page_attr('entryIconGalleryId')
       photo = SemiStatic::Photo.find(e.get_page_attr('entryIconGalleryId'))
       c = content_tag(:a, :href => entry_link_path(e), :class => 'entryIconLink'){
         content_tag(:div, nil, :class => 'entryIcon', :style => "background-image: url('#{photo.img.url}');")
       }
      end

      c + unless e.title.blank? || e.summary_length.blank?
        style_options = e.header_colour.blank? ? {} : {:style => "color: #{e.header_colour}"}

        # Add classes from any PageAttr 'entryTitleClasses'
        class_options = {:class => e.get_page_attr('entryTitleClasses')}

        if linked && !e.link_to_tag
          # Standard sort of link 
          content_tag(h_tag, class_options){ content_tag(:a, e.title, style_options.merge(:href => entry_link(e))) } +
          (e.sub_title.present? ? content_tag(h_sub_tag){ content_tag(:a, e.sub_title, style_options.merge(:href => entry_link(e)))} : '')
        else
          # No link
          content_tag(h_tag, e.title, class_options.merge(style_options)) +
          (e.sub_title.present? ? content_tag(h_sub_tag, e.sub_title) : '')
        end
      end
    end

    def entry_link_path(e)
      if e.link_to_tag && (controller_name != 'tags' || @summaries)
        feature_path(e.tag.slug)
      else
        entry_link(e)
      end
    end

    def entry_path(intended_entry, options = {})

      intended_entry.kind_of?(Integer) && (intended_entry = Entry.find(intended_entry))

      if intended_entry.acts_as_tag.present?
        # SemiStatic::Engine.routes.url_helpers.features_path(intended_entry.acts_as_tag.slug, options)
        feature_path(intended_entry.acts_as_tag.slug, options)
      elsif intended_entry.tag.context_url
        #
        # Get URL in the form "/entries/abcdefg..." and sub the 1st instance of "entries", which will always
        # be at the front, with the context URL
        #
        # Also the options[:only_path] is no longer supported in Rails 5 (see also below) so we have to
        # handle it manually as it may be called by, for example, the sitemap.xml builder
        #
        if options[:only_path] == false
          SemiStatic::Engine.routes.url_helpers.entry_url(intended_entry, options).sub('entries', intended_entry.tag.name.parameterize)
        else
          SemiStatic::Engine.routes.url_helpers.entry_path(intended_entry, options).sub('entries', intended_entry.tag.name.parameterize)
        end
      else
        #
        # We call super (or Rails helper) with the updated intended_entry (which has now been
        # forced to be an Entry object), this will ensure that we get the full URL ie:
        #   /entries/652-my-blog post 
        # rather than just
        #   /entries/652
        #
        # In Rails 5 option[:only_path] no longer works, you should call entry_url instead,
        # but we prefer keep the old option so we check for :only_path here and switch to
        # the correct rails helper. Gotcha here is that if options[:only_path] is nil, ie.
        # not defined, then that is the same as options[:only_path] == true
        #
        if options[:only_path] == false
          SemiStatic::Engine.routes.url_helpers.entry_url(intended_entry, options)
        else
          SemiStatic::Engine.routes.url_helpers.entry_path(intended_entry, options)
        end
      end
    end

    # For GET you can call this rather than entry_path so that entries
    # acting as tags and context urls can be intercepted. Recently we
    # have simplified this by just overriding the entry_path helper
    # (see above)
    def entry_link(intended_entry, options = {})

      # Since the default in Rails 5 url_helper is moving to *_url not *_path we
      # set the option[:only_path] to true by default
      options[:only_path].nil? && options[:only_path] = true

      entry_path(intended_entry, options)
    end

    # Work out the correct path depending on locale
    def feature_path(slug, options = {})
      SemiStatic::Engine.routes.url_helpers.send("#{I18n.locale.to_s}_features_path", slug, options)
    end

    # For GET you should call this rather than feature_path so that
    # any Tags with use_entry_as_index will get mapped to the correct
    # url
    def tag_link(t, options = {})
      if t.use_entry_as_index
        entry_link(t.use_entry_as_index, options)
      else
        feature_path(t.slug)
      end
    end

    def analytics
      if SemiStatic::Engine.config.analytics_partial && Rails.env.production?
        render :partial => SemiStatic::Engine.config.analytics_partial
      end
    end

    #
    # Entry specific header HTML, META, ld+json, etc.
    def entry_header_html
      entry = @entry || @tag&.use_entry_as_index
      entry&.header_html&.html_safe
    end

    def copyright_year
      ("&copy;" + (SemiStatic::Engine.config.has?('copyright_year') || Date.today.year.to_s)).html_safe
    end

    def entry_menu_title(entry)
      entry.alt_title.blank? ? entry.title : entry.alt_title
    end

    def subscriber_content
      @subscriber_content || ((@entry && @tag).nil? ? false : (@entry || @tag).subscriber_content)
    end

    def select_layout(obj)
      'semi_static_' + LAYOUTS[obj.layout_select || 0]
    end

    # This is a legacy from Rails 3 version, should no longer be used but
    # is keep here to prevent breaking old custom partials and view overrides
    def max_menu_tags
      100
    end

    def predefined_tags
      predefined_route.merge(Hash[SemiStatic::Engine.config.predefined.map{|k, v| [k, Rails.application.routes.url_helpers.send(*v)]}])
    end

    #
    # The "sub_menu" is the one that typically goes in the sidebar of a desktop layout and this is the basic layout
    # which is constructed from simply the default Tag or some other Tag(s) set by PageAttrs
    #
    def basic_sub_menu(tags_for_menu, main_tag, entries_for_pagination=nil)
      c = '<div id="semi_static_sidebar_nav">'.html_safe
      tags_for_menu = tags_for_menu.kind_of?(Array) ? tags_for_menu.collect{|t| Tag.find(t)} : [ tags_for_menu ]
      tags_for_menu.compact.each{|t|
        c += content_tag(:h2) do
          link_to t.sidebar_title, tag_link(t), :style => "color: #{main_tag.colour};"
        end
        tag.div :class => 'section' do
          (entries_for_pagination || t.entries_for_navigation).each{|e|
            c += render :partial => 'semi_static/tags/side_bar_entry', :locals => {:e => e}
          }
        end
      }
      if entries_for_pagination
        c += paginate entries_for_pagination, views_prefix: 'semi_static', :remote => true
      end
      c += '</div>'.html_safe
    end

    #
    # Used by the main menus (typically top and slider) to work out which links to which
    # Tags go in their menus
    #
    def menu_from_tag(t)
      if t.menu && t.target_tag.present?
        [(t.target_tag.predefined_class.blank? ? feature_path(t.target_tag.slug) : predefined_tags[t.target_tag.predefined_class]), '#', t.target_name].join
      else
        predefined_tags[t.predefined_class] || feature_path(t.slug)
      end
    end

    def hreflang_tags(root=false)
      c = ''
      langs = []
      if SemiStatic::Engine.config.localeDomains.count > 1 && !(page = @entry || @tag).nil?
        SemiStatic::Engine.config.localeDomains.keys.each{|k|
          if !(link = page.hreflang_link(k, root)).nil?
            c += "<link rel=\"alternate\" href=\"#{link}\" hreflang=\"#{k.to_s}\" />"
            langs << k.to_s
          end
        }
        # If we have any alternate lang links at all then according to the Google recomendations
        # we must also add a META tag for the current page in it's own locale. So we do that
        # here.
        if !langs.blank? && !langs.include?(session[:locale].to_s)
          c += "<link rel=\"alternate\" href=\"#{request.url}\" hreflang=\"#{session[:locale].to_s}\" />"
        end
        c.html_safe
      end
    end

    def construct_url(p, l)
      unless SemiStatic::Engine.config.localeDomains[l]
        return "Cannot find domain for Tag/Page id: #{p.id} and locale: #{l}"
      end

      host = URI.parse(SemiStatic::Engine.config.localeDomains[l]).host
      scheme = URI.parse(SemiStatic::Engine.config.localeDomains[l]).scheme

      if p.kind_of?(Tag)
        if p.predefined_class.present? && !predefined_route[p.predefined_class].nil?
          SemiStatic::Engine.config.localeDomains[l] + predefined_route[p.predefined_class]
        else
          #
          # Cannot use this:
          #   SemiStatic::Engine.routes.url_for(:controller => p.class.to_s.underscore.pluralize, :action => 'show', :slug => p.slug, :host => host)
          # as it would not use the correct locale to get the 'tag_paths[l]', so we have to build the url manually:
          #
          "#{scheme}://#{host}/#{SemiStatic::Engine.config.tag_paths[l]}/#{p.slug}"
        end
      elsif p.kind_of?(Entry)
        if p.acts_as_tag.present?
          #
          # Later Rails don't support :only_path => false, so we have to construct manually
          #
          "#{scheme}://#{host}#{entry_path(p)}"
        else
          entry_path(p, {:host => host, :only_path => false, :protocol => scheme})
        end
      elsif p.kind_of?(String)
        [SemiStatic::Engine.config.localeDomains[l], p].join('/')
      else
        SemiStatic::Engine.routes.url_for(:controller => p.class.to_s.underscore.pluralize, :action => 'show', :id => p.to_param, :host => host, :protocol => scheme)
      end
    end

    def entry_body(e)
      e.simple_text ? simple_format(e.body) : e.body.html_safe
    end

    def entry_summary(e, l = 300, news = false, read_more = nil)
      if e.summary.blank? || (!news && e.use_as_news_summary)
        if e.simple_text
          simple_format(e.body[0..l] + read_more.to_s)
        else
          truncate_html(e.body, :length => l, :omission => read_more || '...') unless (l.nil? || (l < 1))
        end
      else
        simple_format(e.summary + read_more.to_s)
      end
    end

    # This allows us to deal with images that are smaller than expected. We set the max-width inline according
    # to the uploaded file size. This then stops the image from being displayed larger than the origional.
    def image_with_style(e, style, max_width, popup=true, use_alt_img=false)
      alt = e.img&.original_filename&.split('.')&.first&.humanize
      if popup && e.image_popup
        c = "<a class='popable' onclick=\'semiStaticAJAX(\"#{entry_path(e, {:format => :js, :popup => true})}\")\; return false;' href='#'> ".html_safe
      else
        c = ''
      end
      if use_alt_img
        c += image_tag(e.alt_img.url, :alt => alt).html_safe
      elsif max_width
        c += image_tag(e.img_url_for_theme(style), :style => "max-width: #{max_width.to_s + 'px'};", :alt => alt).html_safe
      elsif !e.img_dimensions.blank?
        #
        # If geometry is a %, then take the actual width, else take the max of the actual width or the style width
        #
        if e.img.styles[SemiStatic::Entry::THEME[SemiStatic::Engine.config.theme][style] || style].geometry.split('x').first.include?('%')
          w = e.img_dimensions[0].to_i
        else
          w = [e.img.styles[SemiStatic::Entry::THEME[SemiStatic::Engine.config.theme][style] || style].geometry.split('x').first.to_i, e.img_dimensions[0]].min
        end
        c += image_tag(e.img_url_for_theme(style), :style => "max-width: #{w.to_s + 'px'};", :alt => alt).html_safe
      else
        c += image_tag(e.img_url_for_theme(style), :alt => alt).html_safe
      end
      if popup && e.image_popup
        c += "</a>".html_safe
      end
      c.html_safe
    end

    # Build nice html for a semantic (rich snippet) image. Can deal with different
    # style etc.
    def semantic_entry_image(e, style, max_width=nil, popup=true, use_alt_img=false)
      c = '<figure vocab = "http://schema.org/" typeof="ImageObject"> '.html_safe
      sc = e.raw_title.blank? ? e.image_caption : e.raw_title
      c += "<meta  property='name' content='#{sc}'> ".html_safe
      c += "<div class='#{style.to_s} image_wrapper'>".html_safe
      c += image_with_style(e, style, max_width, popup, use_alt_img)
      c += '</div>'.html_safe
      unless e.image_caption.blank? || style == :home
        c += "<figcaption class='caption'> <div class='caption-inner' property='description'>#{e.image_caption}</div> </figcaption> ".html_safe
      end
      c += '</figure>'.html_safe
    end

    def semantic_photo(p, style, show_title = true, popup = p.popup)
      c = '<figure vocab = "http://schema.org/" typeof="ImageObject"> '.html_safe
      c += "<meta property='name' content='#{p.title}'/>".html_safe
      if popup
        c += "<a class='popable photo' onclick=\'semiStaticAJAX(\"#{photo_path(p, :format => :js, :popup => true)}\")\; return false;' href='#{photo_path(p)}'> ".html_safe
      end
      if show_title
        c += "<h3 property='name'>#{p.title}</h3>".html_safe
      end
      c += image_tag(p.img.url(style), :class => 'photo', :alt => p.title)
      popup && c += '</a>'.html_safe
      unless p.description.blank?
        c += "<figcaption class='caption'> <div class='caption-inner' property='description'>#{p.description}</div> </figcaption> ".html_safe
      end
      c += '</figure>'.html_safe
    end


    # Array of ISO-4217 currency codes, cannot use a hash
    ISO4217 = [['€','EUR'], ['$','USD'], ['£','UKP']]

    def default_currency_sym
      ISO4217.select{|sym, iso| SemiStatic::Engine.config.default_currency == iso}.flatten.first || SemiStatic::Engine.config.default_currency
    end

    def semantic_job_posting(entry)
      return unless (e = entry.job_posting).present?
      jp = entry.job_posting
      c = '<div class="job-posting" typeof="JobPosting" vocab="http://schema.org/"><table>'.html_safe
      c += "<thead><tr><td colspan=2><h2 property='title'>#{jp.title}</h2></td></tr></thead><tbody>".html_safe
      c += "<tr><td colspan=2><h3>Job Description</h3></td></tr>".html_safe
      c += "<tr><td property='description' colspan=2>#{simple_format(jp.description)}</td></tr>".html_safe

      if jp.job_location.present?
        c += "<tr property='jobLocation' typeof='Place'><td>Job Location</td><td property='address'>#{jp.job_location}</td></tr>".html_safe
      end

      [:employmentType, :responsibilities, :industry, :qualifications, :skills].each{|attr|
        unless jp.send(attr.to_s.underscore.downcase).blank?
          c += "<tr><td>#{t(attr)}</td>".html_safe
          c += "<td property='#{attr}'>#{jp.send(attr.to_s.underscore.downcase)}</td></tr>".html_safe
        end
      }

      if jp.base_salary.present?
        # Does the ISO code match one of symbols?
        cur_sym = ((currency = ISO4217.select{|sym, iso| jp.salary_currency == iso}) && currency.flatten.first) || jp.salary_currency

        c += "<tr><td>Base Salary</td><td><span property='salaryCurrency' content='#{jp.salary_currency}'>#{cur_sym} </span>".html_safe

        # The Google SDTT will complain about the salary being text, but it seems it ok, see:
        #   https://github.com/schemaorg/schemaorg/issues/1897#issuecomment-386454642
        c += "<span property='baseSalary'>#{jp.base_salary}</span></td></tr>".html_safe
      end

      c += '</tbody>'.html_safe
      c += '<tbody class="organisation" property="hiringOrganization" typeof="Organization">'.html_safe

      c += "<tr><td colspan=2><h3 property='name'>#{jp.organisation_name}</h3></td></tr>".html_safe
      c += "<tr><td colspan=2>".html_safe

      if jp.organisation_logo.present?
        c += "<img class='floater' src=#{jp.organisation_logo.url} alt='organisation logo' property='Logo'/>".html_safe
      end

      c += "<div property='description'>#{simple_format(jp.organisation_description)}</div>".html_safe
      c += "</td></tr>".html_safe

      # The Google rich snippets checker currently (Nov 2018) signals an error if the property 'location' is used, eg:
      #   c += "<tr><td>Location</td><td property='location'>#{jp.organisation_location}</td></tr>".html_safe
      if jp.organisation_location.present?
        c += "<tr><td>Location</td><td>#{jp.organisation_location}</td></tr>".html_safe
      end

      if jp.organisation_email.present?
        c += "<tr><td>Contact Email</td><td property='email'><a href='mailto:#{jp.organisation_email}'>#{jp.organisation_email}</a></td></tr>".html_safe
      end

      if jp.organisation_telephone.present?
        c += "<tr><td>Contact Telephone</td><td property='telephone'><a href='tel:#{jp.organisation_telephone.delete(' ')}'>#{jp.organisation_telephone}</a></td></tr>".html_safe
      end

      if jp.organisation_department.present?
        c += "<tr><td>Department</td><td property='department'>#{jp.organisation_department}</td></tr>".html_safe
      end

      if jp.organisation_address.present?
        c += "<tr><td>Address</td><td property='address'>#{jp.organisation_address}</td></tr>".html_safe
      end

      c += '</tbody>'.html_safe
      if jp.date_posted.present?
        c += '<tbody>'.html_safe
        c += "<tr><td>Date Posted</td><td property='datePosted'>#{jp.date_posted.strftime("%Y-%m-%d")}</td></tr>".html_safe
        c += '</tbody>'.html_safe
      end
      c += '</table></div>'.html_safe
    end

    def event_registration_url(e)
      e.registration_url.blank? ? new_registration_path(:registration => true, :reason => e.registration_text) : e.registration_url
    end

    # Is registration required for e = Event. Some Events have a Squeeze to allow you make your own custom
    # AJAX to deal with as you wish, so we add the Squeeze ID in the data attr here.
    def event_registration_link(e)
      if e.registration
        "<a class='registration' data-squeezeid=\'#{e.squeeze_id}\' rel='nofollow' href=\'#{event_registration_url(e)}\'>#{t('Register')}</a>".html_safe
      end
    end

    # Events only belong to entries, so we take the entry as a parameter as we can also get other data from this, like the locale
    def semantic_event(entry)
      return unless (e = entry.event).present?
      c = '<div class="event" typeof="Event" vocab="http://schema.org/"><table>'.html_safe
      c += '<thead>'.html_safe
      c += "<tr class='row'><th colspan='2'>".html_safe

      # Is registration required
      c += event_registration_link(e)

      c += "<div property='name'>#{e.name}</div>".html_safe
      c += "</th></tr>".html_safe

      if e.description.present?
        c += "<tr class='row'><td colspan='2' property='description'>#{simple_format(e.description)}</td></tr>".html_safe
      end

      c += '</thead>'.html_safe

      # Attendance mode
      c += "<tbody property='eventAttendanceMode' content=\'#{SemiStatic::Event::ATTENDANCE_MODE_IDS[e.attendance_mode].to_s}\'>".html_safe
      c += "<tr class='row'><td>#{t('attendanceMode')}:</td>".html_safe
      c += "<td>#{t('attendanceModeType.' + SemiStatic::Event::ATTENDANCE_MODE_IDS[e.attendance_mode].to_s)}</td></tr>".html_safe
      c += '</tbody>'.html_safe

      if e.online_url.present?
        c += '<tbody property="location" typeof="VirtualLocation">'.html_safe
        c += "<tr class='row'><td>#{t('OnlineUrl')}: </td><td><span property='url'>#{link_to e.online_url, e.online_url}</span></td></tr>".html_safe
        c += '</tbody>'.html_safe
      end

      if (e.location.present? && e.location_address.present?)
        c += '<tbody property="location" typeof="Place">'.html_safe
        c += "<tr class='row'><td>#{t('location')}: </td><td><span property='name'>#{e.location}</span></td></tr>".html_safe
        c += "<tr class='row'><td>#{t('Address')}: </td><td><span property='address'>#{e.location_address}</span></td></tr>".html_safe
        c += '</tbody>'.html_safe
      end

      # Event status
      c += "<tbody property='eventStatus' content=\'#{SemiStatic::Event::STATUS_IDS[e.status].to_s}\'>".html_safe
      c += "<tr class='row'><td>#{t('status')}:</td>".html_safe
      c += "<td>#{t('eventStatus.' + SemiStatic::Event::STATUS_IDS[e.status].to_s)}</td></tr>".html_safe
      c += '</tbody>'.html_safe

      e.start_date.present? &&
        (c += "<tr class='row'><td>#{t('start_date')}: </td><td><span property='startDate' content=\'#{e.start_date.iso8601}\'>#{l(e.start_date, :format => "%a, %d %b %Y %H:%M")}</span></td></tr>".html_safe )

      # Duration in ISO 8601 minutes format: https://en.wikipedia.org/wiki/ISO_8601#Durations
      e.duration.present? && (c += "<tr class='row'><td>#{t('duration')}: </td><td><span property='duration' content=\'#{e.duration.to_s + 'M'}\'>#{[e.duration, t('minutes')].join(' ')}</span></td></tr>".html_safe )
      e.in_language.present? && (c += "<tr class='row'><td>#{t('language')}: </td><td><span property='inLanguage'>#{e.in_language}</span></td></tr>".html_safe )

      # Offer start
      #
      # The structure and order of the meta is awkward, espcially if no price is set, hence the weird 'currency_and_url_meta' insertion
      #
      if (((e.offer_min_price.present? && e.offer_max_price.present?) || e.offer_price.present?) && e.offer_price_currency.present?)

        currency_meta_done = false
        currency_and_url_meta = "<meta property='priceCurrency' content=\'#{ISO4217.select{ |sym, code| e.offer_price_currency == sym }.flatten.last}\'/><meta property='url' content=\'#{construct_url(entry.merged_main_entry, entry.locale)}\'/>"

        c += '<tbody property="offers" typeof="Offer">'.html_safe

        if e.offer_price.present?
          c += "<tr class='row'><td>#{currency_and_url_meta}#{t('Price')}: </td><td property='price' content=\'#{sprintf('%.2f', e.offer_price)}\'>#{number_to_currency(e.offer_price, :unit => e.offer_price_currency, :precision => 2, :locale => entry.locale.to_sym)}</td></tr>".html_safe
          currency_meta_done = true
        end

        if (e.offer_min_price.present? && e.offer_max_price.present?)
          c += "<tr class='row'><td>".html_safe
          unless currency_meta_done
            c += currency_and_url_meta.html_safe
          end
          c += "#{t('Price_range')}: </td><td typeof='PriceSpecification' property='PriceSpecification'>".html_safe
          c += "<span property='minPrice' content=\'#{sprintf('%.2f', e.offer_min_price)}\'>#{number_to_currency(e.offer_min_price, :unit => e.offer_price_currency, :precision => 2, :locale => entry.locale.to_sym)} - </span>".html_safe
          c += "<span property='maxPrice' content=\'#{sprintf('%.2f', e.offer_max_price)}\'>#{number_to_currency(e.offer_max_price, :unit => e.offer_price_currency, :precision => 2, :locale => entry.locale.to_sym)}</span>".html_safe
          c += "</td></tr>".html_safe
        end

        c += '</tbody>'.html_safe
      end
      # Offer end

      c += '</table></div>'.html_safe
    end

    def squeeze(entry)
      return unless (s = entry.squeeze).present?
      "<div id=\'squeeze-tease_#{entry.squeeze.id.to_s}\'><a class='squeeze' rel='nofollow' onclick='semiStaticAJAX(\"#{squeeze_path(s, :popup => false)}\")\; return false;' href='#{squeeze_path(s)}'>#{simple_format(s.teaser)}</a></div>".html_safe
    end


    #
    # Need to hand craft the share button links and add a Google GA Event trigger
    #
    def social_shares(e)
      return unless (e.facebook_share || e.instagram_share || e.linkedin_share || e.xing_share || e.twitter_share)
      c = '<div class="social button-wrapper"> '.html_safe
      if e.facebook_share
        c+= "<a class='fb-share' title='#{t('ShareOnFacebook')}' onclick='var that=this;ga(\"send\", \"event\", \"SocialShare\", \"Facebook\");setTimeout(function(){location.href=that.href;},400);return false;' href='https://www.facebook.com/sharer/sharer.php?u=#{request.url}'>#{t('Share')}</a>".html_safe
      end
      if e.instagram_share
        c+= "<a class='ig-share' title='#{t('FollowOnInstagram')}' onclick='var that=this;ga(\"send\", \"event\", \"SocialShare\", \"Instagram\");setTimeout(function(){location.href=that.href;},400);return false;' href='https://www.instagram.com/#{SemiStatic::Engine.config.instagramID&.sub('@', '')}'>#{t('Share')}</a>".html_safe
      end
      if e.xing_share
        c+= "<a class='xi-share' title='#{t('ShareOnXing')}' onclick='var that=this;ga(\"send\", \"event\", \"SocialShare\", \"Xing\");setTimeout(function(){location.href=that.href;},400);return false;' href='https://www.xing-share.com/app/user?op=share;sc_p=xing-share;url=#{request.url}'>#{t('Share')}</a>".html_safe
      end
      if e.linkedin_share
        c+= "<a class='li-share' title='#{t('ShareOnLinkedIn')}' onclick='var that=this;ga(\"send\", \"event\", \"SocialShare\", \"LinkedIn\");setTimeout(function(){location.href=that.href;},400);return false;' href='https://www.linkedin.com/cws/share?url=#{request.url}'>#{t('Share')}</a>".html_safe
      end
      if e.twitter_share
        c+= "<a class='tw-share' title='#{t('ShareOnTwitter')}' onclick='var that=this;ga(\"send\", \"event\", \"SocialShare\", \"Twitter\");setTimeout(function(){location.href=that.href;},400);return false;' href='https://twitter.com/intent/tweet?url=#{request.url}&hashtags=#{SemiStatic::Engine.config.site_name.parameterize}'>#{t('Share')}</a>".html_safe
      end
      if e.email_share
        c+= mail_to nil, t('Share'), {:subject => e.merged_main_entry.title, :body => request.url, :title => t('ShareViaEmail'), :class => 'em-share', :onclick => 'var that=this;ga(\'send\', \'event\', \'SocialShare\', \'Email\');setTimeout(function(){location.href=that.href;},400);return false;'}
      end
      c += '</div>'.html_safe
    end

    def switch_box_tag(name, value = "1", checked = false, options = {})
      html_options = { "type" => "checkbox", "name" => name, "id" => sanitize_to_id(name), "value" => value }.update(options.stringify_keys)
      html_options["checked"] = "checked" if checked
      '<div class="onoffswitch">'.html_safe +
      "<input type='checkbox' name='onoffswitch' class='onoffswitch-checkbox' id='#{html_options["id"]}' #{html_options["checked"]}><label class='onoffswitch-label' for='#{html_options["id"]}'>".html_safe +
      '<div class="onoffswitch-inner"></div><div class="onoffswitch-switch"></div></label></div>'.html_safe
    end
  
    # By default will show a flag icon for each alternate locale or translation. If flag is set to :locales it
    # will instead show each language symbol as 2 characters. If :flags or :text, you also get the current language
    # highlighted
    def locales(display = :flags)
      c = ''
      # TODO: The checking for entry or tag is primative and does not cover predefined tags
      page = @entry || @tag
      ls = ((display == :locales) || (display == :allflags) ? SemiStatic::Engine.config.localeDomains : SemiStatic::Engine.config.localeDomains.reject{|k, v| k.to_s == I18n.locale.to_s})
      unless ((display == :locales) && (ls.size == 1))
        ls.each{|l, u|
          if u.downcase == 'translate' 
            link = "http://translate.google.com/translate?hl=&sl=auto&tl=#{l}&u=#{url_encode(request.url)}"
          else
            # If this is a special page, with no tag or entry, then it will not be seoable so just point locales to the root of the alternate locale website
            page.nil? && (link = u)
          end
          if (display == :flags) || (display == :allflags)
            c+= "<li class='locale #{l}'><a href='#{link || page.hreflang_link(l) || u}'>#{image_tag("flags/" + l + ".png", :alt => "locale #{l}")}</a></li>".html_safe
          elsif display == :text
            c+= "<li class='locale #{l}'><a href='#{link || page.hreflang_link(l) || u}'>#{I18n.t(l)}</a></li>".html_safe
          else
            if session[:locale] == l
              c+= "<li class='locale  #{l} selected'><a href='#{link || page.hreflang_link(l) || u}'>#{l}</a></li>".html_safe
            else
              c+= "<li class='locale #{l}'><a href='#{link || page.hreflang_link(l) || u}'>#{l}</a></li>".html_safe
            end
          end
        }
      end
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
      if defined?(Admin)
        main_app.new_admin_session_path
      else
        main_app.new_user_session_path
      end
    end

    def semi_static_path_for_admins
      if defined?(Admin)
        main_app.admins_path
      else
        main_app.users_path
      end
    end

    def semi_static_path_for_admin_session
      if defined?(Admin)
        main_app.admin_session_path
      else
        main_app.user_session_path
      end
    end

    def seo_title
      if @seo
        sanitize((@seo.title || @title || SemiStatic::Engine.config.site_name).gsub(/'/, '&#39;'))
      else
        sanitize((@title || SemiStatic::Seo.master_title || SemiStatic::Engine.config.site_name).gsub(/'/, '&#39;'))
      end
    end

    def seo_description
      if @seo && !@seo.description.blank?
        @seo.description
      elsif @entry && !@entry.summary.blank?
        truncate(strip_tags(@entry.summary), :length => 140, :separator => ' ')
      elsif SemiStatic::Seo.master_description.present?
        SemiStatic::Seo.master_description
      else
        false
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
      if @entry&.img.present?
        # img_url_for_theme is actually always a relative path
        request.protocol + request.host + @entry.img_url_for_theme
      else
        asset_url(SemiStatic::Engine.config.logo_image || 'logo-top.png')
      end
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
        main_app.send(*SemiStatic::Engine.config.app_dashboard).html_safe
      else
        if defined?(Admin)
          main_app.destroy_admin_session_path
        else
          main_app.destroy_users_session_path
        end
      end
    end

    #
    # Only used for parralax theme
    #
    def banner_skrollr_offset(banner)
      (banner.img_height(SemiStatic::Engine.config.theme, :desktop)/4 - 50).to_s
    end

    #
    # In Rails 4/5 we checked page_attr 'csrfMetaTagViaSsi' to have the meta tags
    # done via webserver SSI. This was useful in the case of having a static page
    # that needs valid csrf tags, like page with a PUT action. We only did this if
    # in production mode like this:
    #
    #   page ||= (controller_name == 'entries' ? @entry : @tag)
    #   if page && page.get_page_attr('csrfMetaViaSsi') && Rails.env.production?
    #     '<!--#include file="/site/csrf_meta_tags" -->'.html_safe
    #   else ...
    #
    # With Rails 5 we have per-form CSRF tokens by default. The server config was
    # difficult enough already, per-form CSRF made SSI provision of the token
    # almost impossible. So we take a different approach and get a new
    # authenticity_token that will match the session via AJAX.
    #
    # With the new AJAX method of getting the CSRF Token it is not required
    # that we do it at this point, but it's also a reasonable place to set
    # it up as the method is only called one per page and the javascript checks all
    # forms in the page. If we did it on every form in a page it would be more
    # complex and probably less efficient.
    #
    def semi_static_csrf_meta_tags(page=nil)
      page ||= (controller_name == 'entries' ? @entry : @tag)
      if page && page.get_page_attr('csrfFormAuth')
        csrf_script = <<-EOL
          <script>
          function semiStaticLoadCSRF(){
            semiStaticAJAX('/site/csrf_meta_tags?dummy')
          };
          addSemiStaticLoadEvent(semiStaticLoadCSRF);
          </script>
        EOL
        content_for(:ujs) { csrf_script.html_safe }
      end
      csrf_meta_tags
    end

    #
    # These are given in the configration and will be something like this:
    #
    # 
    # config.custom_meta_tags = {
    #   'de' => {'facebook-domain-verification' => 'afli2m9gdwf4crzi99ebxjsoj33j4g'},
    #   'en' => {'facebook-domain-verification' => 'maywr8l04nx9hh7qz56be7uwsotlis'}
    # }
    #
    def semi_static_custom_meta_tags
      SemiStatic::Engine.config.custom_meta_tags[I18n.locale.to_s].inject(''){|res, (name, value)|
        res << "<meta name=\"#{name}\" content=\"#{value}\">"
      }.html_safe if SemiStatic::Engine.config.respond_to?('custom_meta_tags')
    end

    #
    # In sprockets 2.x the the 'find_asset' method was just what we needed, we could find and asset
    # very easily like this:
    #   ObjectSpace.each_object(Sprockets::Environment).first.find_asset('home_theme.js')
    #
    # or with the standard API call like this:
    #   Rails.application.assets.find_asset('home_theme.js')
    #
    # We could even get the contents of that asset very easily like this:
    #   ObjectSpace.each_object(Sprockets::Environment).first.find_asset('home.css').source.html_safe
    #
    # With sprockets 3.x this still works in development more but not in production! The replacememnt
    # method is supposed to be:
    #   Rails.application.assets.find_asset('home_theme.js')
    # but this only works if you set:
    #   Rails.application.config.assets.compile = true
    # but we don't want to do this, it's not recomended and we anyway want to precompile all assets.
    #
    # This is quite a drawback and rather strange that development and production have different API's
    # 
    # The solution is via our own methods find_asset and asset_source. Carefull to only use
    # asset_source on .js, .css files etc, not images
    # 
    def find_asset(filename)
      path = ""
      if Rails.application.assets
        Rails.application.assets.find_asset(filename).pathname
      else
        Rails.application.assets_manifest.assets.each do |f,p|
          if File.basename(f) == filename
            path = p
          end
        end
        path.blank? ? nil : File.join(Rails.public_path, 'assets', path)
      end
    end

    def asset_source(filename)
      if Rails.application.assets
        Rails.application.assets.find_asset(filename) && Rails.application.assets.find_asset(filename).source.html_safe
      else
        if path = find_asset(filename)
          File.read(path).html_safe
        else
          nil
        end
      end
    end

    private

    def column(fc, colclass)
      c = "<div class='col #{colclass}'><div class='inner'>".html_safe
      c += "<h3>#{fc.name}</h3>".html_safe unless fc.name.blank?
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
