module LRUGHelpers
  def unless_url(matches, &html_block)
    unless current_resource.url =~ matches
      concat_content(capture_html &html_block)
    end
  end

  def if_url(matches, &html_block)
    if current_resource.url =~ matches
      concat_content(capture_html &html_block)
    end
  end

  def with_page(slug_match, &html_block)
    page = sitemap.where(:slug => slug_match).first
    if page
      concat_content(capture_html page, &html_block)
    end
  end

  def with_children_of(page, args = {}, &html_block)
    all_children = page.children
    start = args[:offset] || 0
    stop = if args[:limit]
        start + args[:limit] -1
      else
        -1
      end
    all_children[start..stop].each { |child| concat_content(capture_html(child, &html_block)) }
  end

  def date_format(date, format)
    date.strftime(format)
  end
end
