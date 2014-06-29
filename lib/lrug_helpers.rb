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

end
