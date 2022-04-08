module SemiStatic
  module DashboardHelper

    def modal_close
      '<button type="button" class="close" data-dismiss="modal" aria-label="Close"> <span aria-hidden="true">&times;</span> </button>'.html_safe
    end

    #
    # Javascript response to AJAX to load the partial in the argument
    #
    def js_modal_load(partial, hide=true)
      if hide
        "$('.modal').modal('hide');$('#generalModal .modal-content').html('#{escape_javascript(render :partial => partial)}');$('#generalModal').modal();".html_safe
      else
        "$('#generalModal .modal-content').html('#{escape_javascript(render :partial => partial)}');$('#generalModal').modal();".html_safe
      end
    end

    def nav_link(link_text, controller_name, link_path)
      class_name = ((@menu_class || controller.controller_name) == controller_name) ? 'active' : ''

      content_tag(:li, :class => class_name) do
        link_to link_text, link_path, :class => 'app-menu__item'
      end
    end

    def nav_icon_link(link_text, controller_name, link_path, icon_class, link_class = '')
      class_name = [((@menu_class || controller.controller_name) == controller_name) ? 'active' : '', link_class].reject(&:empty?).join(' ')

      content_tag(:li, :class => class_name) do
        link_to link_path, :class => "app-menu__item #{class_name}" do
          "<i class='app-menu__icon fa #{icon_class}'></i><span class='app-menu__label'>#{link_text}</span>".html_safe
        end
      end
    end

    #
    # Form, and form-like,  elements with bootstrap styling
    #
 
    #
    # Creates a bootstrap styled checkbox from a form boolean. The label is contructed from the attribute
    # name unless a "text" is provided. An optional infomarker can also be provided inside the .input-group
    # class that will open up an associated .infobox (uses javascript).
    #
    def labeled_checkbox(f, box, text=nil, infomarker=false, klass=nil, force_checked=false)
      text ||= box.to_s.humanize
      klass ||= f.object.class.name.split('::').last.underscore
      checked = force_checked && "checked='checked'"
      checked ||= f.object&.send(box) ? "checked='checked'" : ''
      infomarker_html = infomarker ? "<span class='infomarker' data-marker='#{infomarker.to_s}'></span>" : ''
      "<div class='input-group'>#{infomarker_html}<div class='input-group-prepend'> <label class='input-group-text' for='#{['semi_static', klass, box.to_s].join('_')}'>#{text}</label> </div> <div class='form-control mt-2'> <div class='checkbox-wrapper'> <input name='#{klass}[#{box.to_s}]' type='hidden' value='0'><input type='checkbox' value='1' #{checked} name='#{klass}[#{box.to_s}]' id='#{['semi_static', klass, box.to_s].join('_')}'> </div> </div> </div>".html_safe
    end

    def labeled_textfield(f, attr, text=nil, infomarker=false)
      text ||= attr.to_s.humanize
      klass = f.object.class.name.split('::').last.underscore
      infomarker_html = infomarker ? "<span class='infomarker' data-marker='#{infomarker.to_s}'></span>" : ''
      input_html = f.text_field(attr, {:class => 'form-control mt-2'})

      "<div class='input-group'>#{infomarker_html}<div class='input-group-prepend'> <label class='input-group-text' for='#{klass}_#{attr}'>#{text}</label></div>#{input_html}</div>".html_safe
    end

    #
    # Like labeled_textfield, but not a form field, or even a readonly form field, but it appears like one
    #
    def completed_textfield(obj, attr, text=nil)
      "<div class='input-group'><div class='input-group-prepend'> <label class='input-group-text'>#{text || t(attr)}</label></div><div class='form-control mt-2 completed'>#{obj.send(attr)}</div></div>".html_safe
    end

    def labeled_selectbox(f, attr, select_options, text=nil, infomarker=false)
      text ||= attr.to_s.humanize
      klass = f.object.class.name.split('::').last.underscore
      infomarker_html = infomarker ? "<span class='infomarker' data-marker='#{infomarker.to_s}'></span>" : ''
      select_html = f.select(attr, select_options, {}, {:class => 'form-control mt-2'})

      "<div class='input-group'>#{infomarker_html}<div class='input-group-prepend'> <label class='input-group-text' for='#{klass}_#{attr}'>#{text}</label></div>#{select_html}</div>".html_safe
    end

  end
end
