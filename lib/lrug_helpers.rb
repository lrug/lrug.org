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
    # offset / limit do the right thing if given nil
    ChildrenQuery.new(page).
      offset(args[:offset]).
      limit(args[:limit]).
      all.
      each { |child| concat_content(capture_html(child, &html_block)) }
  end

  class ChildrenQuery
    def initialize(page)
      @page = page
      @resources = page.children
    end
    attr_reader :resources
    include ::Middleman::Sitemap::Queryable::API
  end

  def date_format(date, format)
    date.strftime(format) unless date.nil?
  end
end
