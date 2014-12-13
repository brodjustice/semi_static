module SemiStatic
  module UsersHelper
    def roles_for(user)
      if user.respond_to?(roles)
        r = user.roles.collect{|r| r.name}
        if r.empty?
          t('Warning_no_role_assigned')
        else
          r.join(' ')
        end
      end
    end
  
    def restricted_role_check_box(user, role, ltext, opts={})
      opts['disabled'] = 'disabled' unless current_user.admin?
      opts = opts.merge({:id => dom_id(role), :class => 'role_check_box'})
      l = label_tag dom_id(role), t(ltext)
      c = check_box_tag "user[role_ids][]", role.id, @user.role_ids.include?(role.id), opts
      (c + l).html_safe
    end
  
    def role_form_for(user)
      cboxs = ""
      if current_user.admin?
        cboxs << hidden_field_tag("user[role_ids][]", nil)
        Role.all.each{|r| cboxs << "<div class='cb'>" + restricted_role_check_box(user, r, r.name) + "</div>"}
      else
        cboxs = "<div class='cb readonly'>" + user.roles.collect{|r| r.name.humanize}.join("<br/>") + "</div>"
      end
      cboxs.html_safe
    end
  end
end
