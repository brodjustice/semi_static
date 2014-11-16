module SemiStatic
  module TagsHelper
    PREDEFINED = {
      'Home' => SemiStatic::Engine.routes.url_helpers.home_path,
      'References' => SemiStatic::Engine.routes.url_helpers.references_path,
      'Contact' => SemiStatic::Engine.routes.url_helpers.new_contact_path,
      'Gallery' => SemiStatic::Engine.routes.url_helpers.photos_path
    }
  
    def icon(tag)
      if Tag.use_sprites?
       "<div class='icon sprite mini' id=\"sprite_#{tag.position.to_s}\"></div>".html_safe
      elsif tag.icon_in_menu
       "<div class='icon'><img src=\"#{tag.icon.url(:standard)}\"/></div>".html_safe
      end
    end
  end
end
