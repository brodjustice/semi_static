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

    #
    # Form elements with bootstrap styling
    #
 
    #
    # Creates a bootstrap styled checkbox from a form boolean. The label is contructed from the attribute
    # name unless a "text" is provided. An optional infomarker can also be provided inside the .input-group
    # class that will open up an associated .infobox (uses javascript).
    #
    def labeled_checkbox(f, box, text=nil, infomarker=false)
      text ||= box.to_s.humanize
      klass = f.object.class.name.split('::').last.downcase
      checked = f.object.send(box) ? "checked='checked'" : ''
      infomarker_html = infomarker ? "<span class='infomarker' data-marker='#{infomarker.to_s}'></span>" : ''
      "<div class='input-group'>#{infomarker_html}<div class='input-group-prepend'> <label class='input-group-text' for='#{['semi_static', klass, box.to_s].join('_')}'>#{text}</label> </div> <div class='form-control mt-2'> <div class='checkbox-wrapper'> <input name='#{klass}[#{box.to_s}]' type='hidden' value='0'><input type='checkbox' value='1' #{checked} name='#{klass}[#{box.to_s}]' id='#{['semi_static', klass, box.to_s].join('_')}'> </div> </div> </div>".html_safe
    end

    def labeled_textfield(f, attr, text=nil, infomarker=false)
      text ||= attr.to_s.humanize
      klass = f.object.class.name.split('::').last.downcase
      infomarker_html = infomarker ? "<span class='infomarker' data-marker='#{infomarker.to_s}'></span>" : ''
      input_html = "<input class='form-control mt-2' type='text' value='#{f.object.send(attr)}' name='#{klass}[#{attr}]' id='#{klass}_#{attr}'>".html_safe

      "<div class='input-group'>#{infomarker_html}<div class='input-group-prepend'> <label class='input-group-text' for='#{klass}_#{attr}'>#{text}</label></div>#{input_html}</div>".html_safe
    end

    def labeled_selectbox(f, attr, select_options, text=nil, infomarker=false)
      text ||= attr.to_s.humanize
      klass = f.object.class.name.split('::').last.downcase
      infomarker_html = infomarker ? "<span class='infomarker' data-marker='#{infomarker.to_s}'></span>" : ''
      select_html = f.select(attr, select_options, {}, {:class => 'form-control mt-2'})

      "<div class='input-group'>#{infomarker_html}<div class='input-group-prepend'> <label class='input-group-text' for='#{klass}_#{attr}'>#{text}</label></div>#{select_html}</div>".html_safe
    end

  end
end
