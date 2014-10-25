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
      :admin => ['tags', 'entries', 'banners', 'footer', 'gallery', 'references', 'users', 'contacts', 'agreements', 'seos', 'system', 'signout'],
      :user => []
    }
  
    #
    # Note below that the "selected" arg is set after checking
    # against only the first 3 characters. This is a bit of a
    # hack but saves a lot of time messing about with pluralisation
    # 
    def menu_for(role)
      MENU[role.to_sym].collect{|p|
        send(p, role, ("\'selected\'" if (@selected || params[:controller]).include?(p[0..2])))
      }.join().html_safe
    end
  
    private
  
    def seos(role, cl_str = nil)
      "<div class='nutshell spaced' #{cl_str}><a href=\"#{seos_path}\">SEO</a></div>"
    end

    def references(role, cl_str = nil)
      "<div class='nutshell spaced' #{cl_str}><a href=\"#{references_path}\">References</a></div>"
    end

    def gallery(role, cl_str = nil)
      "<div class='nutshell spaced' #{cl_str}><a href=\"#{photos_path}\">Gallery</a></div>"
    end
  
    def contacts(role, cl_str = nil)
      "<div class='nutshell spaced' #{cl_str}><a href=\"#{contacts_path}\">Contacts</a></div>"
    end
  
    def banners(role, cl_str = nil)
      "<div class='nutshell spaced' #{cl_str}><a href=\"#{banners_path}\">Banners</a></div>"
    end
  
    def agreements(role, cl_str = nil)
      "<div class='nutshell spaced' #{cl_str}><a href=\"#{agreements_path}\">Agreements</a></div>"
    end
  
    def users(role, cl_str = nil)
      "<div class='nutshell spaced' #{cl_str}><a href=\"#{users_path}\">Users</a></div>"
    end
  
    def entries(role, cl_str = nil)
      "<div class='nutshell spaced' #{cl_str}><a href=\"#{entries_path}\">Entries</a></div>"
    end
  
    def tags(role, cl_str = nil)
      "<div class='nutshell spaced' #{cl_str}><a href=\"#{tags_path}\">Tags</a></div>"
    end
  
    def system(role, cl_str = nil)
      "<div class='nutshell spaced' #{cl_str}><a href=\"#{dashboard_path(role)}\">System</a></div>"
    end
  
    def signout(role, cl_str = nil)
      "<div class='nutshell spaced' #{cl_str}><a href=\"#{destroy_user_session_path}\" data-method='delete'>Sign Out</a></div>"
    end
  
    def footer(role, cl_str = nil)
      "<div class='nutshell spaced' #{cl_str}><a href=\"#{fcols_path}\">Footer</a></div>"
    end
  end
end
