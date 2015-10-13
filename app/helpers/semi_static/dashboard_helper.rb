module SemiStatic
  module DashboardHelper

    # Intruments are the actual displays shown on the overview page
    INSTRUMENTS = {
      :visitor => [],
      :admin => ['semi_static/dashboards/admin/contacts', 'semi_static/dashboards/admin/tags', 'semi_static/dashboards/admin/system'],
      :user => ['semi_static/dashboards/user/profile']
    }
  
    # The menu is the list of top level intruments 
    MENU = {
      :visitor => [],
      :admin => ['tags', 'entries', 'sidebars', 'products', 'banners', 'footer', 'gallery', 'references',
                  'admins', 'contacts', 'agreements', 'seos', 'newsletters',
                  'subscribers', 'click_ads', 'system'],
      :user => []
    }
  
    #
    # Note below that the "selected" arg is set after checking
    # against only the first 3 characters. This is a bit of a
    # hack but saves a lot of time messing about with pluralisation
    # 
    def menu_for(role)
      html = MENU[role.to_sym].collect{|p|
        send(p, role, ("\'selected\'" if (@selected || params[:controller]).include?(p[0..2])))
      }.join().html_safe
      unless SemiStatic::Engine.config.dashboard_menu_additions.nil?
        SemiStatic::Engine.config.dashboard_menu_additions.each{|title, url_method|
          html += "<div class='nutshell spaced'><a href=\"#{main_app.send(url_method)}\">#{title.humanize}</a></div>".html_safe
        }
      end
      html.html_safe
    end

    private

    def subscribers(role, cl_str = nil)
      "<div class='nutshell spaced' #{cl_str}><a href=\"#{semi_static.subscribers_path}\">Subscribers</a></div>"
    end

    def newsletters(role, cl_str = nil)
      "<div class='nutshell spaced' #{cl_str}><a href=\"#{semi_static.newsletters_path}\">Newsletters</a></div>"
    end

    def seos(role, cl_str = nil)
      "<div class='nutshell spaced' #{cl_str}><a href=\"#{semi_static.seos_path}\">SEO</a></div>"
    end

    def references(role, cl_str = nil)
      "<div class='nutshell spaced' #{cl_str}><a href=\"#{semi_static.references_path}\">References</a></div>"
    end

    def gallery(role, cl_str = nil)
      "<div class='nutshell spaced' #{cl_str}><a href=\"#{semi_static.photos_path}\">Gallery</a></div>"
    end
  
    def contacts(role, cl_str = nil)
      "<div class='nutshell spaced' #{cl_str}><a href=\"#{semi_static.contacts_path}\">Contacts</a></div>"
    end
  
    def banners(role, cl_str = nil)
      "<div class='nutshell spaced' #{cl_str}><a href=\"#{semi_static.banners_path}\">Banners</a></div>"
    end
  
    def agreements(role, cl_str = nil)
      "<div class='nutshell spaced' #{cl_str}><a href=\"#{semi_static.agreements_path}\">Agreements</a></div>"
    end
  
    def admins(role, cl_str = nil)
      "<div class='nutshell spaced' #{cl_str}><a href=\"#{semi_static_path_for_admins}\">Admins</a></div>"
    end
  
    def entries(role, cl_str = nil)
      "<div class='nutshell spaced' #{cl_str}><a href=\"#{semi_static.entries_path}\">Entries</a></div>"
    end
  
    def sidebars(role, cl_str = nil)
      "<div class='nutshell spaced' #{cl_str}><a href=\"#{semi_static.sidebars_path}\">Sidebars</a></div>"
    end
  
    def products(role, cl_str = nil)
      "<div class='nutshell spaced' #{cl_str}><a href=\"#{semi_static.products_path}\">Products</a></div>"
    end
  
    def tags(role, cl_str = nil)
      "<div class='nutshell spaced' #{cl_str}><a href=\"#{semi_static.tags_path}\">Tags</a></div>"
    end
  
    def click_ads(role, cl_str = nil)
      "<div class='nutshell spaced' #{cl_str}><a href=\"#{semi_static.click_ads_path}\">Click Ads</a></div>"
    end
  
    def system(role, cl_str = nil)
      "<div class='nutshell spaced' #{cl_str}><a href=\"#{semi_static.semi_static_dashboard_path}\">System</a></div>"
    end
  
    def signout(role, cl_str = nil)
      "<div class='nutshell spaced' #{cl_str}><a href=\"#{semi_static_path_for_admin_session}\" data-method='delete'>Sign Out</a></div>"
    end
  
    def footer(role, cl_str = nil)
      "<div class='nutshell spaced' #{cl_str}><a href=\"#{semi_static.fcols_path}\">Footer</a></div>"
    end
  end
end
