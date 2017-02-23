module VerticalNavHelper
  
  def vertical_nav_for(navable)
    vertical_menu_for(navable)
  end

  # Generates the HTML code for a vertical menu, where the given navable object,
  # e.g. a Page or a User, is the currently active element.
  #
  def vertical_menu_for(navable)
    if navable
      @ancestor_navables = ancestor_navables(navable)
      @active_navable = navable
      @active_navables = [@active_navable]
      @child_navables = child_navables(navable)

      menu_elements_html(@ancestor_navables, :ancestor) +
      menu_element(@active_navable, :active) +
      menu_elements_html(@child_navables, :child)
    end
  end

  def show_vertical_nav?
    (not @hide_vertical_nav) && @navable && Rails.cache.fetch([@navable, "show_vertical_nav?"]) do
      @navable.present? && (@navable != Page.find_root) && (@navable.children.count + @navable.ancestors.count > 1)
    end
  end

  def child_navables(navable)
    non_hidden_navables(navable.navable_children, :child).sort_by do |object|
      [ ['Page', 'Group'].index(object.class.base_class.name),  # pages above groups
      object.created_at]
    end
  end

  private

  def ancestor_navables(navable)
    non_hidden_navables(navable.nav_node.ancestor_navables, :ancestor)
  end

  def non_hidden_navables(navables, element_class)
    navables.select do |navable|
      not(navable.nav_node.hidden_menu and element_class == :child) and
      not(navable.nav_node.slim_menu and element_class == :ancestor)
    end
  end

  def menu_elements_html(objects, element_class)
    objects.select { |object| can?(:read, object) }.collect do |object|
      menu_element(object, element_class)
    end.join.html_safe
  end

  def menu_element( object, element_class )
    content_tag( :li, :class => "#{element_class} #{object.class.name.downcase}" ) do
      link_to(menu_element_title(object), current_tab_path(object), data: {
        vertical_nav_path: vertical_nav_path(navable_type: object.class.base_class.name, navable_id: object.id)
      })
    end
  end

  def menu_element_title(object)
    if append_corporation_to_menu_element_title?(object)
      "#{object.title} (#{object.corporation.title})"
    else
      object.title
    end
  end

  def append_corporation_to_menu_element_title?(object)
    object.kind_of?(Group) &&
      object.corporation &&
      (not object.corporation.in?(@ancestor_navables + @active_navables)) &&
      (not object.corporation == object)
  end
end
