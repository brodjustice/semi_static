module SemiStatic
  module DashboardHelper

    def modal_close
      '<button type="button" class="close" data-dismiss="modal" aria-label="Close"> <span aria-hidden="true">&times;</span> </button>'.html_safe
    end

    #
    # Javascript response to AJAX to load the partial in the argument
    #
    def js_modal_load(partial)
      "$('.modal').modal('hide');$('#generalModal .modal-content').html('#{escape_javascript(render :partial => partial)}');$('#generalModal').modal();".html_safe
    end

    def nav_link(link_text, controller_name, link_path)
      class_name = ((@menu_class || controller.controller_name) == controller_name) ? 'active' : ''

      content_tag(:li, :class => class_name) do
        link_to link_text, link_path, :class => 'app-menu__item'
      end
    end

    def nav_icon_link(link_text, controller_name, link_path, icon_class)
      class_name = ((@menu_class || controller.controller_name) == controller_name) ? 'active' : ''

      content_tag(:li, :class => class_name) do
        link_to link_path, :class => "app-menu__item #{class_name}" do
          "<i class='app-menu__icon fa #{icon_class}'></i><span class='app-menu__label'>#{link_text}</span>".html_safe
        end
      end
    end
  end
end
