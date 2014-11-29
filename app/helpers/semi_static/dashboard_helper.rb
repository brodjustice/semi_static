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
      :admin => ['tags', 'entries', 'banners', 'footer', 'gallery', 'references', 'admins', 'contacts', 'agreements', 'seos', 'system'],
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

    def semi_static_path_for_admin_sign_out
      if SemiStatic::Engine.config.app_dashboard
        link_to 'Done', main_app.send(*SemiStatic::Engine.config.app_dashboard)
      else
        if defined?(CanCan)
          link_to 'Done', main_app.destroy_users_session_path, :method => :delete
        else
          link_to 'Done', main_app.destroy_admin_session_path, :method => :delete
        end
      end
    end

    private

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
  
    def tags(role, cl_str = nil)
      "<div class='nutshell spaced' #{cl_str}><a href=\"#{semi_static.tags_path}\">Tags</a></div>"
    end
  
    def system(role, cl_str = nil)
      "<div class='nutshell spaced' #{cl_str}><a href=\"#{semi_static_dashboard_path}\">System</a></div>"
    end
  
    def signout(role, cl_str = nil)
      "<div class='nutshell spaced' #{cl_str}><a href=\"#{semi_static_path_for_admin_session}\" data-method='delete'>Sign Out</a></div>"
    end
  
    def footer(role, cl_str = nil)
      "<div class='nutshell spaced' #{cl_str}><a href=\"#{semi_static.fcols_path}\">Footer</a></div>"
    end
  end
end
