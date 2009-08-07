module NavigationHelper
  def page_links_for_navigation
    link = Struct.new(:name, :url)
    [link.new("Home", root_path),
     link.new("Archives", archives_path)] +
      Page.find(:all, :order => 'title').collect {|page| link.new(page.title, page_path(page.slug))}
  end

  def category_links_for_navigation
    popular_tags.collect {|tag| tag_link(tag) }
  end

  def tag_link(tag)
    link = Struct.new(:name, :url)
    # @popular_tags ||= Tag.find(:all).reject {|tag| tag.taggings.empty? }.sort_by {|tag| tag.taggings.size }.reverse
    # @popular_tags.collect {|tag| link.new(tag.name, posts_path(:tag => tag.name)) }
    link.new(tag.name, posts_path(:tag => tag))
  end

  def popular_tags
    @popular_tags || Tag.find(:all).reject {|tag| tag.taggings.empty? }.sort_by {|tag| tag.taggings.size }.reverse
  end

  def cloud_tags
    Post.tag_counts
  end
  
  def tag_cloud_nav
    output = ''
    tag_cloud cloud_tags, %w(tag1 tag2 tag3 tag4) do |tag, css_class| 
      link = tag_link(tag)
      output << link_to(h(link.name), link.url, :class => css_class)
    end
    content_tag :div, output, :class => 'tag_cloud'
  end
  

  def class_for_tab(tab_name, index)
    classes = []
    classes << 'current' if "admin/#{tab_name.downcase}" == params[:controller]
    classes << 'first'   if index == 0
    classes.join(' ')
  end
end
