module General
  LAYOUTS = {
    0 => 'application',
    1 => 'home',
    2 => 'full' 
  }

  def layout_select(obj)
    'semi_static_' + LAYOUTS[obj.layout_select || 0]
  end
end
