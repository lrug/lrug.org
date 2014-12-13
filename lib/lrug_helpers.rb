module LRUGHelpers
  def page_title(for_page = current_page)
    yield_content(:title) || for_page.data.title
  end

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
      where(:status => 'Published').
      order_by(:published_at => args[:order] || :asc).
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

  def show_sponsors(for_page = current_page)
    partial "sponsors", locals: { for_page: for_page }
  end

  def meeting_pages
    sitemap
      .resources
      .select { |page| page_has_data?(page, status: 'Published', category: "meeting") }
      .sort_by { |page| page.data.published_at }
      .reverse
  end

  def page_has_data?(page, args)
    args.all? do |key, value|
      page.data[key.to_s] == value
    end
  end

  def content_part_exists?(part_name, page, inherit: false)
    find_page_part(part_name, page, inherit: inherit).present?
  end

  def render_content_part(part_name, page, inherit: false)
    part = find_page_part(part_name, page, inherit: inherit)
    if part
      if part['filter'].present?
        Tilt.new(part['filter']) do
          Tilt.new('.erb') do
            part['content']
          end.render(self)
        end.render(self)
      else
        part['content']
      end
    else
      ''
    end
  end

  private
  def find_page_part(part_name, page, inherit: false)
    if page.data.parts? && page.data.parts.has_key?(part_name)
      page.data.parts[part_name]
    elsif inherit && page.parent.present?
      find_page_part(part_name, page.parent, inherit: inherit)
    else
      nil
    end
  end

  public
  def date_format(date, format)
    date.strftime(format) unless date.nil?
  end

  def render_markdown(md)
    Tilt['markdown'].new do
      md
    end.render
  end
end
